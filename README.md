# bilibili视频下载器
~~~shell script
Author: gdream@yeah.net
~~~
> 特此声明：此项目仅供学习使用。如有侵权等法律问题，请尽快联系我删除。如有人用作违法或商业等用途，因此产生的一切法律问题由其个人负责和承担，本项目维护者概不负责。



## 使用方式
注意: 为了合并音视频，本机需要安装ffmpeg，并配置环境变量（Docker方式不需要安装）。([下载ffmpeg](https://ffmpeg.org/download.html))

[一、Python env](###python)

[二、Golang env](###golang)

[三、Docker env](###docker)



## 使用详明
### 二进制文件
[Release地址](https://github.com/ggdream/bilibili/releases)
~~~sh
将路径添加到环境变量中即可在全路径下使用
~~~

### Python
[分支地址](https://github.com/ggdream/bilibili/tree/python)
~~~sh
$ git clone -b python https://github.com/ggdream/bilibili.git
$ pip install -r requirements.txt
$ python bilibili.py <BV_Number>                # 注意bilibili.py的路径
~~~

### Golang
[分支地址](https://github.com/ggdream/bilibili/tree/golang)
~~~sh
$ go get https://github.com/ggdream/bilibili    # 会自动编译成二进制文件到$GOBIN下
$ down <BV_Number>                              # 其他功能使用($down --help)查看帮助
~~~

### Docker
~~~sh
$ docker run -d -v /tmp:/data ggdream/bilibili <BV_Number>  # 其他功能使用($down --help)查看帮助
~~~
