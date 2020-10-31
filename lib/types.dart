class Url{
  static String url1(String id) => "https://www.bilibili.com/video/$id";
  static String url2(String id, int p) => "https://www.bilibili.com/video/$id?p=$p";
}

class Meta{
  static const String userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36";

  static Map<String, String> headers(String id) => {
    "referer": Url.url1(id),
    "user-agent": userAgent
  };
  static Map<String, String> headersRange(String id){
    var map = headers(id);
    map["range"] = "bytes=0-";
    return map;
  }
}
