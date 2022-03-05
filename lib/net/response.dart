import 'core.dart';

class VideoMetaInfoModel extends BaseModel {
  late final String bvid;
  late final String title;
  late final String cover;
  late final String author;
  late final String desc;
  late final int counter;
  late final int duration;
  final List<_IdAndSubtitleModel> videos = [];

  @override
  VideoMetaInfoModel fromJson(data) {
    final Map<String, dynamic> videoData = data['videoData'];

    bvid = videoData['bvid'];
    title = videoData['title'];
    cover = videoData['pic'].replaceAll('\\u002F', '/');
    author = videoData['owner']['name'];
    desc = videoData['desc'];
    counter = videoData['videos'];
    duration = videoData['duration'];

    for (var item in videoData['pages']) {
      final model = _IdAndSubtitleModel.fromJson(item);
      videos.add(model);
    }

    return this;
  }
}

class _IdAndSubtitleModel {
  final int id;
  final String title;
  final int duration;

  _IdAndSubtitleModel.fromJson(Map<String, dynamic> data)
      : id = data['cid'],
        title = data['part'],
        duration = data['duration'];
}

class VideoLinksModel extends BaseModel {
  final List<_LinksModel> links = [];

  @override
  VideoLinksModel fromJson(data) {
    final Map<String, dynamic> dash = data['data']['dash'];

    final audio = dash['audio'][0]['base_url'];
    final video = dash['video'][0]['base_url'];
    final id = dash['video'][0]['id'];
    final model = _LinksModel(id: id, video: video, audio: audio);
    links.add(model);

    return this;
  }
}

class _LinksModel {
  final int id;
  final String video;
  final String audio;

  _LinksModel({
    required this.id,
    required this.video,
    required this.audio,
  });
}
