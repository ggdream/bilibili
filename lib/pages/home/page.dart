import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final _controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: bodyView(),
      floatingActionButton: floatingBtn(),
    );
  }

  FloatingActionButton floatingBtn() {
    return FloatingActionButton(
      heroTag: 'home',
      onPressed: _controller.toDetailPage,
      child: const Icon(Icons.cloud_download_rounded),
    );
  }

  AppBar appBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: textFieldView(),
      actions: [
        IconButton(
          onPressed: _controller.view,
          icon: const Icon(Icons.web_asset_rounded),
        ),
      ],
    );
  }

  Widget bodyView() {
    return _controller.obx(
      (_) => coreView(),
      onLoading: const Center(
        child: RefreshProgressIndicator(),
      ),
      onEmpty: const Center(
        child: Text('呜呜呜,没找到呢~'),
      ),
    );
  }

  Widget coreView() {
    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      children: [
        ListTile(
          title: const Text('标题'),
          subtitle: Text(_controller.title),
        ),
        ListTile(
          title: const Text('作者'),
          subtitle: Text(_controller.author),
        ),
        ListTile(
          title: const Text('简介'),
          subtitle: Text(_controller.desc),
        ),
        ListTile(
          title: const Text('分集数'),
          subtitle: Text(_controller.counter.toString()),
        ),
        ListTile(
          title: const Text('视频总时长'),
          subtitle: Text(
            '${_controller.duration ~/ 60}分${_controller.duration % 60}秒',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GestureDetector(
            onLongPress: _controller.saveCover,
            child: Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(16),
              child: ClipRRect(
                child: Image.network(_controller.cover),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 84),
      ],
    );
  }

  Widget textFieldView() {
    return Obx(() {
      return TextField(
        focusNode: _controller.focusNode,
        cursorColor: Colors.black,
        controller: _controller.editingController,
        onChanged: _controller.onChange,
        decoration: InputDecoration(
          suffixIcon: _controller.data.isEmpty
              ? null
              : InkWell(
                  onTap: _controller.clearText,
                  borderRadius: BorderRadius.circular(16),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.black,
                  ),
                ),
          hintText: '想搜些什么呢？',
          filled: true,
          fillColor: const Color(0xfff5f5f5),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: _getInputBorder,
          enabledBorder: _getInputBorder,
          errorBorder: _getInputBorder,
        ),
      );
    });
  }

  final _getInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
    borderSide: BorderSide.none,
  );
}
