import 'package:file_selector/file_selector.dart';

class Selector {
  static Future<String?> pickDirectoryPath({
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    return await getDirectoryPath(
      initialDirectory: initialDirectory,
      confirmButtonText: confirmButtonText,
    );
  }
}
