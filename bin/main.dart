import 'dart:io';

import 'package:bilibili/core.dart';

import 'cli.dart';

main(List<String> args)  {
//  cli(args);
  Dash d = Dash("BV1bb411W7CA", "", 1 << 3, false);
  d.fetch().then((_) {
    d.getDetails();
  });
}
//
//cli(args);
//Dash d = Dash(id, path, cNum, all);
//d.fetch().then((_) {
//d.getDetails();
//});

