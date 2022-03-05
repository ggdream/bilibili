import 'package:get/get.dart';

import 'package:bilibili/pages/detail/detail.dart';
import 'package:bilibili/pages/home/home.dart';
import 'package:bilibili/pages/notfind/notfind.dart';

class AppRouter {
  AppRouter._();

  static const initRoute = home;
  static final notFoundRoute = GetPage(
    name: notfind,
    page: () => const NotfindPage(),
  );

  static const home = '/';
  static const notfind = '/404';
  static const detail = '/view';

  static final List<GetPage> routes = [
    GetPage(name: home, page: () => HomePage()),
    GetPage(name: detail, page: () => DetailPage()),
  ];
}
