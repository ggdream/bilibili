import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

class Toast {
  static dynamic text(String text,
          {Color? backgroundColor, Duration? duration}) =>
      showToast(
        text,
        backgroundColor: backgroundColor,
        duration: duration,
      );
}
