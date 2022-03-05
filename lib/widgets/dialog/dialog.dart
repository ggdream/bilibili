import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool> showAskAgainDialog([String text = '确定此操作吗？']) async {
  return (await showDialog(
    context: Get.context!,
    builder: (ctx) => AskAgainView(text: text),
  )) ?? false;
}

class AskAgainView extends StatelessWidget {
  const AskAgainView({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('提示'),
      content: Text(text),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: true),
          child: const Text('确定'),
        ),
        TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('取消'),
        ),
      ],
    );
  }
}
