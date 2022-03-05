class Config {
  final net = _Net();
  final meta = _Meta();
  final preset = _Preset();

}

/// Network config, include http and websocket
class _Net {
  final baseURL = '';
  final timeout = const Duration(seconds: 5);
}

class _Meta {
  final appName = '哔哩下载器';
}

class _Preset {
  final avatar =
      'https://raw.githubusercontent.com/mocaraka/assets/main/picture/841.jpg';
}
