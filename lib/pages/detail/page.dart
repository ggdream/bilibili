import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller.dart';

class DetailPage extends StatelessWidget {
  DetailPage({Key? key}) : super(key: key);

  final _controller = Get.put(DetailController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: ListView.separated(
        itemCount: _controller.items.length,
        itemBuilder: (context, index) {
          final model = _controller.items[index];
          return Obx(() {
            return CheckboxListTile(
              title: Text(model.title),
              subtitle: Text('${model.duration ~/ 60}分${model.duration % 60}秒'),
              value: _controller.data[index].value,
              onChanged: (value) => _controller.onChanged(index, value),
            );
          });
        },
        separatorBuilder: (context, index) {
          return const Divider(
            height: 0,
            thickness: .4,
          );
        },
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
      ),
      title: Text(_controller.title),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: _controller.startDownload,
          icon: const Icon(Icons.cloud_download_rounded),
        ),
      ],
    );
  }
}
