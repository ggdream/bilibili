import 'dart:io';
import 'package:args/args.dart';


String  id;
String  path;
int     cNum;
bool    all;

void cli(List<String> args){
  var app = ArgParser();

  app.addFlag('all', abbr: 'a', defaultsTo: false, negatable: false, callback: (v) => all = v);
  app.addOption('path', abbr: 'p', defaultsTo: '', callback: (v) => path = v);
  app.addOption('cnum', abbr: 'c', defaultsTo: '8', callback: (v) => cNum = int.parse(v));

  var a = app.parse(args);

  try {
    id = a.arguments.last;
  } finally {}

  if (!id.startsWith("BV") && !id.startsWith("av")) {
    print("The video number is wrong or not in the last position.");
    exit(-1);
  }
}
