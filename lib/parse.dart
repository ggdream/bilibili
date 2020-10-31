import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http ;
import 'package:bilibili/types.dart';
import 'package:path/path.dart';



class Parser{
  final String  id;
  String _baseInfo;
  String _path;
  List<String>  titles;

  Parser(this.id, this._path);


  Future<void> fetch() async {
    var res =  await http.get(Url.url1(this.id), headers: Meta.headers(this.id));
    this._baseInfo = this.reBase(res.body);
    this.titles = this.getSubTitlesArray();

    var dir = Directory(join(this._path, "dst"));
    if (! await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  String reBase(String data) => data.split("window.__INITIAL_STATE__=")[1].split(";(function")[0];
  String rePlay(String data) => data.split("window.__playinfo__=")[1].split("</script>")[0];

  String getBaseInfoString() => this._baseInfo;
  Map<String, dynamic> getBaseInfoMap() => json.decode(this._baseInfo);

  int getNumber() => this.getBaseInfoMap()["videoData"]["videos"];
  int getTotalTime() => this.getBaseInfoMap()["videoData"]["duration"];
  String getAuthor() => this.getBaseInfoMap()["videoData"]["owner"]["name"];
  String getTitle() => this.getBaseInfoMap()["videoData"]["title"];
  String getDesc() => this.getBaseInfoMap()["videoData"]["desc"];
  String getPubDate() => DateTime.fromMillisecondsSinceEpoch(this.getBaseInfoMap()["videoData"]["pubdate"] * 1000).toString();

  String getAvID() => this.getBaseInfoMap()["aid"].toString();
  String getBvID() => this.getBaseInfoMap()["bvid"];

  List<String> getSubTitlesArray() {
    List<String> data = [];
    List.from(this.getBaseInfoMap()["videoData"]["pages"]).forEach((element) => data.add(element["part"]));
    return data;
  }
  void show(){
    var pages = this.getBaseInfoMap()["videoData"]["pages"];
    for (int i=0;i<pages.length;i++) {
      print("$i     ${pages[i]["part"]}");
    }
  }
}

