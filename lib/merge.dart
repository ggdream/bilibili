

import 'package:bilibili/dash.dart';
import 'package:path/path.dart';
import 'package:process_run/shell_run.dart';

class Merge{
  final String _path;
  final List<Detail> _details;

  Merge(this._path, this._details);

  Do() async {
    await this._details.forEach((element) {
      cmd(this._path, element);
    });
  }
}



cmd(String path, Detail detail) async {
  print('>>Merge ${join(path, "dst", "${detail.rank}")}');
  await run('ffmpeg -i ${join(path, "src", "${detail.rank}.mp4")} -i ${join(path, "src", "${detail.rank}.mp3")} -c:v copy -c:a copy ${join(path, "dst", "${detail.rank}.mp4")}');
  print('<<Merge ${join(path, "dst", "${detail.rank}")}');
}
