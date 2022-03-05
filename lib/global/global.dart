import 'cache.dart';
import 'config.dart';

/// App global information manager
class Global {
  Global._();

  static Future<void> init() async {}

  /// Cache: temp data store key-value
  static final cache = Cache();

  /// Config: app basic config data key-value
  static final config = Config();
}
