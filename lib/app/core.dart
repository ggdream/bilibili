import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';

import 'package:bilibili/global/global.dart';
import 'package:bilibili/router/router.dart';
import 'package:bilibili/styles/styles.dart';

import 'preview.dart';

class Core extends StatelessWidget {
  const Core({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      scrollBehavior: _CustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      enableLog: !kReleaseMode,
      builder: _builder,
      useInheritedMediaQuery: true,
      locale: Preview.locale(context),
      getPages: AppRouter.routes,
      initialRoute: AppRouter.initRoute,
      unknownRoute: AppRouter.notFoundRoute,
      theme: AppTheme.global,
      title: Global.config.meta.appName,
      defaultTransition: Transition.cupertino,
    );
  }

  Widget _builder(context, widget) {
    widget = GestureDetector(
      child: widget,
      onTap: () => hideKeyboard(context),
    );

    widget = OKToast(
      child: widget!,
      position: ToastPosition.bottom,
      radius: 6,
      textPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
    );

    return EasyLoading.init(builder: Preview.builder)(context, widget);
  }

  void hideKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus!.unfocus();
    }
  }
}

class _CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
