import 'package:flutter/material.dart';

import 'core.dart';
import 'init.dart';
import 'preview.dart';

class App {
  static void run() async {
    await initialize();
    runApp(entry);
    await initializeLate();
  }

  static Widget get entry {
    return const Preview(child: Core());
  }
}
