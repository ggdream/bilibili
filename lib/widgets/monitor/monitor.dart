import 'package:flutter/material.dart';

class MonitorView extends StatefulWidget {
  const MonitorView({
    Key? key,
    required this.child,
    this.onInactive,
    this.onResumed,
    this.onPaused,
    this.onDetached,
  }) : super(key: key);

  final Widget child;
  final void Function()? onInactive; // 任何暂停的时候
  final void Function()? onResumed; // 后台切到前台
  final void Function()? onPaused; // 前台切到后台
  final void Function()? onDetached; // App结束时

  @override
  _MonitorViewState createState() => _MonitorViewState();
}

class _MonitorViewState extends State<MonitorView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _appStateHandler(state);
  }

  void _appStateHandler(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        if (widget.onInactive != null) widget.onInactive!();
        break;
      case AppLifecycleState.resumed:
        if (widget.onResumed != null) widget.onResumed!();
        break;
      case AppLifecycleState.paused:
        if (widget.onPaused != null) widget.onPaused!();
        break;
      case AppLifecycleState.detached:
        if (widget.onDetached != null) widget.onDetached!();
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
