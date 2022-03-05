import 'package:bilibili/tools/loading/loading.dart';
import 'package:bilibili/widgets/dialog/dialog.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:bilibili/net/net.dart';
import 'package:bilibili/router/router.dart';

import 'model.dart';

class HomeController extends GetxController with StateMixin {
  final data = ''.obs;

  String bvid = '';
  String title = '';
  String cover = '';
  String author = '';
  String desc = '';
  int counter = 0;
  int duration = 0;
  final List<PartModel> videos = [];

  final focusNode = FocusNode();
  final editingController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    change(null, status: RxStatus.empty());
    _applyPromission();
  }

  @override
  void dispose() {
    focusNode.dispose();
    editingController.dispose();
    super.dispose();
  }

  void onChange(String text) => data.value = text;

  void clearText() => editingController.clear();

  Future<void> view() async {
    focusNode.unfocus();

    final url = editingController.text;
    if (url.isEmpty) return;

    final bvid = url.split('/').last;
    await _getVideoMetaInfo(bvid);
  }

  Future<void> toDetailPage() async {
    if (!status.isSuccess) return;

    final args = {
      'title': title,
      'bvid': editingController.text.split('/').last,
      'data': videos,
    };
    await Get.toNamed(AppRouter.detail, arguments: args);
  }

  Future<void> _applyPromission() async {
    if (!GetPlatform.isWeb && GetPlatform.isMobile) {
      await [Permission.storage, Permission.manageExternalStorage].request();
    }
  }

  Future<void> _getVideoMetaInfo(String bvid) async {
    change(null, status: RxStatus.loading());

    final res = await Net.to.getVideoMetaInfo(bvid);
    if (res == null) {
      change(null, status: RxStatus.empty());
      return;
    }

    bvid = res.bvid;
    title = res.title;
    cover = res.cover;
    author = res.author;
    desc = res.desc;
    counter = res.counter;
    duration = res.duration;

    videos.clear();
    for (var item in res.videos) {
      final model = PartModel(
        title: item.title,
        duration: item.duration,
      );
      videos.add(model);
    }

    change(null, status: RxStatus.success());
  }

  Future<void> saveCover() async {
    final res = await Get.dialog<bool>(
      const AskAgainView(text: '要保存该封面吗？'),
    );
    if (res != true) return;

    Loading.show('保存封面中');
    final status = await GallerySaver.saveImage(cover);

    await Loading.close();
    if (status == true) {
      showToast('保存成功');
    } else {
      showToast('保存失败');
    }
  }
}
