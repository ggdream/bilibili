import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:bilibili/net/net.dart';

import 'init_native.dart' if (dart.library.html) 'init_web.dart';

Future<void> initialize() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureApp();

  HttpOverrides.global = _HttpOverrides();

  Get.put(Net());
}

Future<void> initializeLate() async {
  await configureAppLate();

  const style = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  );
  SystemChrome.setSystemUIOverlayStyle(style);
}

class _HttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }

  // @override
  // String findProxyFromEnvironment(Uri url, Map<String, String>? environment) {
  //   environment = environment ?? {};
  //   if (GetPlatform.isLinux) {
  //     environment['http_proxy'] = '127.0.0.1:8889';
  //     environment['https_proxy'] = '127.0.0.1:8889';
  //   } else if (GetPlatform.isWindows) {
  //     environment['http_proxy'] = '127.0.0.1:10809';
  //     environment['https_proxy'] = '127.0.0.1:10809';
  //   }
  //   return super.findProxyFromEnvironment(url, environment);
  // }
}
