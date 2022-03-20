import 'dart:io';

import 'package:ffmpeg_kit_flutter_min/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_min/ffmpeg_session.dart';
import 'package:get/get.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path/path.dart' show joinAll, dirname;
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell_run.dart';

import 'package:bilibili/net/net.dart';
import 'package:bilibili/pages/home/home.dart';
import 'package:bilibili/tools/loading/loading.dart';
import 'package:bilibili/tools/selector/selector.dart';
import 'package:bilibili/tools/toast/toast.dart';

class DetailController extends GetxController {
  final String title = Get.arguments['title'];
  final String bvid = Get.arguments['bvid'];
  final List<PartModel> items = Get.arguments['data'];

  final List<RxBool> data = List.generate(
    Get.arguments['data'].length,
    (index) => false.obs,
  );

  String? _desktopPath;

  void onChanged(int index, bool? value) {
    if (value == null) return;

    data[index].value = value;
  }

  Future<void> startDownload() async {
    if (GetPlatform.isDesktop) {
      _desktopPath = await Selector.pickDirectoryPath();
      if (_desktopPath == null) return;
    }

    final List<int> archive = [];
    for (var i = 0; i < data.length; i++) {
      if (data[i].value) archive.add(i + 1);
    }

    final counter = archive.length;
    for (var i = 0; i < counter; i++) {
      Loading.show('${i + 1}/$counter\n${items[i].title}\n下载中');
      await _download(archive[i]);
      await Loading.close();
    }

    Toast.text('下载完成', duration: const Duration(seconds: 3));
  }

  Future<void> _download(int page) async {
    final res = await Net.to.getVideoLinks(bvid, page);
    if (res == null) return;

    final links = res.links[0];

    final tmp = await getTemporaryDirectory();
    final vName = joinAll([tmp.path, '$bvid-$page.h264']);
    final aName = joinAll([tmp.path, '$bvid-$page.aac']);
    final dName = joinAll([tmp.path, '$bvid-$page.mp4']);
    final fName = '${items[page - 1].title}.mp4';

    await Net.to.download(links.video, vName, bvid);
    await Net.to.download(links.audio, aName, bvid);

    if (GetPlatform.isDesktop) {
      await _mergeDesktop(
        vName: vName,
        aName: aName,
        dName: joinAll([_desktopPath!, fName]),
      );
    } else {
      await _merge(
        vName: vName,
        aName: aName,
        dName: dName,
        fName: fName,
      );
    }

    await File(vName).delete();
    await File(aName).delete();
    if (await File(dName).exists()) {
      await File(dName).delete();
    }
  }

  Future<bool?> _merge({
    required String vName,
    required String aName,
    required String dName,
    required String fName,
  }) async {
    final session = await FFmpegSession.create(
      FFmpegKitConfig.parseArguments(
          '-hide_banner -i "$vName" -i "$aName" -c copy -y "$dName"'),
      null,
      null,
      null,
      null,
    );
    await FFmpegKitConfig.ffmpegExecute(session);

    return await GallerySaver.saveVideo(dName, albumName: fName);
  }

  Future<void> _mergeDesktop({
    required String vName,
    required String aName,
    required String dName,
  }) async {
    late final String exec;
    if (GetPlatform.isWindows) {
      exec = 'ffmpeg.exe';
    } else {
      exec = 'ffmpeg';
    }
    final binExeDir = dirname(Platform.resolvedExecutable);
    final execPath = joinAll([binExeDir, exec]);

    try {
      await Shell().run(
        '$execPath -hide_banner -i "$vName" -i "$aName" -c copy -y "$dName"',
      );
    } catch (e) {
      Toast.text(e.toString());
    }
  }
}
