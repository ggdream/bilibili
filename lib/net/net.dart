import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';

import 'package:bilibili/global/global.dart';
import 'package:bilibili/tools/toast/toast.dart';

import 'response.dart';

class Net extends GetConnect {
  static Net get to => Get.find();

  @override
  void onInit() {
    super.onInit();

    httpClient.timeout = Global.config.net.timeout;
    httpClient.addRequestModifier(_requestModifier);
  }

  Future<void> download(String url, String dst, String bvid) async {
    final opts = BaseOptions(
      connectTimeout: Global.config.net.timeout.inMilliseconds,
      headers: {
        'referer': 'https://www.bilibili.com/video/$bvid',
        'range': 'bytes=0-',
        'user-agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.51 Safari/537.36',
      },
    );
    await Dio(opts).download(url, dst);
  }

  Future<void> downloadCover(String url, String dst) async {
    final opts = BaseOptions(
      connectTimeout: Global.config.net.timeout.inMilliseconds,
      headers: {
        'referer': 'https://www.bilibili.com/',
        'range': 'bytes=0-',
        'user-agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.51 Safari/537.36',
      },
    );
    await Dio(opts).download(url, dst);
  }

  Future<VideoMetaInfoModel?> getVideoMetaInfo(String bvid) async {
    final url = 'https://www.bilibili.com/video/$bvid';
    final html = await httpGet<String>(url);
    if (html == null) return null;

    final res1 = html.split('window.__INITIAL_STATE__=');
    if (res1.length != 2) return null;

    final res2 = res1.last.split(';(function');
    final data = json.decode(res2.first);

    return VideoMetaInfoModel().fromJson(data);
  }

  Future<VideoLinksModel?> getVideoLinks(String bvid, int no) async {
    final url = 'https://www.bilibili.com/video/$bvid';
    final html = await httpGet<String>(
      url,
      query: {'p': no.toString()},
    );
    if (html == null) return null;

    final res1 = html.split('window.__playinfo__=');
    if (res1.length != 2) return null;

    final res2 = res1.last.split('</script>');
    final data = json.decode(res2.first);

    return VideoLinksModel().fromJson(data);
  }

  Future<String?> getBvidFromShortUrl(String url) async {
    httpClient.followRedirects = false;
    final res = await get(url);
    httpClient.followRedirects = true;

    return res.headers?['location'];
  }

  Future<T?> httpGet<T>(
    String url, {
    Map<String, dynamic>? query,
  }) async {
    final response = await get(url, query: query);

    final bodyData = response.bodyString;
    if (response.statusCode == null) {
      Toast.text('网络异常');
    }
    if (bodyData == null || response.statusCode != 200) return null;

    try {
      return json.decode(bodyData);
    } catch (e) {
      return bodyData.toString() as T;
    }
  }

  Future<Request> _requestModifier(Request request) async {
    request.headers.addAll({
      'user-agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/99.0.4844.51 Safari/537.36',
      'referer': request.url.toString(),
    });
    return request;
  }
}
