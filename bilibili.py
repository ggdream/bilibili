import os
import re
import json
import time
import requests
import asyncio
from ffmpy3 import FFmpeg
from aiohttp import request


class GetUrl:
    def __init__(self, bvid: str):
        self.bvid = bvid
        self.__url1 = f"https://www.bilibili.com/video/{bvid}"
        self.__url2 = f"https://www.bilibili.com/video/{bvid}?p=%d"

        self.__headers = {
            "referer": self.__url1,
            "user-agent": "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.89 Safari/537.36"
        }
        self.number, self.pages = self.__parsefirst()

    @staticmethod
    def getpage(data: str) -> dict:
        res = re.findall('window.__INITIAL_STATE__=(.*?);\(function', data)[0]
        return json.loads(res)

    @staticmethod
    def getplay(data: str) -> dict:
        res = re.findall('window.__playinfo__=(.*?)</script>', data)[0]
        return json.loads(res)

    def __parsefirst(self) -> tuple:
        data = requests.get(self.__url1, self.__headers).content.decode()
        page_page = self.getpage(data)
        return page_page["videoData"]["videos"], page_page["videoData"]["pages"]

    async def grab(self, num: int, maps: dict):
        async with request('GET', self.__url2 % num, headers=self.__headers) as res:
            data = await res.text()
            dash = self.getplay(data)["data"]["dash"]
            print(json.dumps(dash))
            maps[str(num)] = {
                "video": dash["video"][0]["baseUrl"],
                "audio": dash["audio"][-1]["baseUrl"],
                "title": self.pages[num - 1]["part"]
            }

    async def fetch(self, maps: dict):
        tasks = [self.grab(i + 1, maps) for i in range(self.number)]
        await asyncio.wait(tasks)
        await asyncio.sleep(10)


class Download:
    def __init__(self, bv: str, path: str, maps: dict):
        self.maps = maps
        self.path = path

        self.__headers = {
            "range": "bytes=0-",
            "referer": f"https://www.bilibili.com/video/{bv}",
            "user-agent": "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.89 Safari/537.36"
        }
        self.__create_file()

    def __create_file(self):
        if not os.path.exists(f'{self.path}/src/'):
            os.makedirs(f'{self.path}/src/')
        if not os.path.exists(f'{self.path}/dst/'):
            os.makedirs(f'{self.path}/dst/')

    async def __down(self, num: str, dash: dict, isVideo: bool):
        async with request('GET', dash["video"] if isVideo else dash["audio"], headers=self.__headers) as res:
            with open(f'{self.path}/src/{num}.{"mp4" if isVideo else "mp3"}', 'wb') as f:
                while True:
                    chunk = await res.content.read(1 << 10)
                    if not chunk:
                        break
                    f.write(chunk)

    async def downs(self, num: str, semaphore: asyncio.Semaphore):
        async with semaphore:
            dash = self.maps[num]
            print("video download start:", dash["title"])
            await self.__down(num, dash, True)
            print("video download completed:", dash["title"])

            print("audio download start:", dash["title"])
            await self.__down(num, dash, False)
            print("audio download completed:", dash["title"])

    async def fetch(self, semNumber: int):
        semaphore = asyncio.Semaphore(semNumber)
        tasks = [self.downs(i, semaphore) for i in self.maps.keys()]
        await asyncio.wait(tasks)
        await asyncio.sleep(10)


class Merge:
    def __init__(self, path: str, maps: dict):
        self.maps = maps
        self.path = path

    def merge(self, num: str):
        ff = FFmpeg(
            inputs={
                f'{self.path}/src/{num}.mp4': None,
                f'{self.path}/src/{num}.mp3': None,
            },
            outputs={
                f'{self.path}/dst/{self.maps[num]["title"]}.mp4': '-c:v h264 -c:a ac3'
            }
        )
        ff.run()
        print("merge completed", self.maps[num]["title"])

    def go(self):
        pass


if __name__ == '__main__':
    bvid = input("视频编号：")
    path = input("存储路径：")
    semaphores = eval(input("并发数量："))
    processes = eval(input("进程数量："))

    av_urls_map = {}
    g = GetUrl(bvid)
    asyncio.run(g.fetch(av_urls_map))

    if not os.path.exists(path):
        os.makedirs(path)
    with open(f'{path}/map.json', 'a') as f:
        json.dump(av_urls_map, f, ensure_ascii=False)

    d = Download(bvid, path, av_urls_map)
    asyncio.run(d.fetch(semaphores))

    try:
        from concurrent.futures.process import ProcessPoolExecutor      # version >= 3.8
    except ImportError:
        from concurrent.futures import ProcessPoolExecutor              # version < 3.8

    m = Merge(path, av_urls_map)
    with ProcessPoolExecutor(max_workers=processes) as pool:
        for num in av_urls_map.keys():
            pool.submit(m.merge, num)
