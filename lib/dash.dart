import 'dart:convert';
import 'dart:io';

import 'package:bilibili/merge.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:dio/dio.dart';

import 'package:bilibili/parse.dart';
import 'package:bilibili/types.dart';

class Detail{
  final String  title;
  final int     rank;
  final int     time;
  final String  vLink;
  final String  aLink;

  Detail(this.rank, this.title, this.time, this.vLink, this.aLink);
}


class Dash extends Parser{
  final int     _cNum;
  final bool    _all;
  final String  _path;

  Dio _dio;

  Map<int, Detail>  _details = {};

  Dash(String id, this._path, this._cNum, this._all) : this._dio = Dio(BaseOptions(headers: Meta.headersRange(id))), super(id, _path);


  Future<void> _getDetail(int p) async {
    var res =  await get(Url.url2(this.id, p+1), headers: Meta.headers(this.id));
    var data = json.decode(super.rePlay(res.body))["data"]["dash"];

    Detail d = Detail(
        p+1,
        this.titles[p],
        data["duration"],
        data["video"][0]["baseUrl"],
        data["audio"][0]["baseUrl"]
    );
    this._details[p] = d;

    await this._down(this._dio, d);
    await cmd(this._path, d);
  }

  void getDetails() {
    for (int i=0;i<this.getNumber();i++) {
      this._getDetail(i);
    }
  }

  Map<int, Detail> d() => _details;

  _down(Dio dio, Detail detail) async {

    print("${DateTime.now()}        -- video ${detail.rank} >>");
    await dio.download(detail.vLink, join(this._path, "src", "${detail.rank}.mp4"));
    print("${DateTime.now()}        -- video ${detail.rank} <<");

    print("${DateTime.now()}        -- audio ${detail.rank} >>");
    await dio.download(detail.aLink, join(this._path, "src", "${detail.rank}.mp3"));
    print("${DateTime.now()}        -- audio ${detail.rank} <<");
  }

  void down() {
    print(this._details);
    var headers = Meta.headersRange(this.id);
    Dio dio = Dio(BaseOptions(headers: headers));
    for (int i=0;i<this.getNumber();i++) {
      this._down(dio, this._details[i]);
    }
  }
}
