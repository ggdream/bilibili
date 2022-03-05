import 'package:flutter_easyloading/flutter_easyloading.dart';

class Loading {
  static Future<void> show(String text) async {
    await EasyLoading.show(
      status: text,
      maskType: EasyLoadingMaskType.clear,
    );
  }

  static Future<void> close() async {
    await EasyLoading.dismiss();
  }
}
