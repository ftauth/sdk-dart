library ftauth_flutter_platform_interface;

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'src/method_channel_ftauth.dart';

export 'src/config.dart';
export 'src/platform_exception_codes.dart';

/// The interface that implementations of FTAuth must implement.
///
/// Platform implementations should extend this class rather than implement it as `FTAuth`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [FTAuthPlatformInterface] methods.
abstract class FTAuthPlatformInterface extends PlatformInterface {
  FTAuthPlatformInterface() : super(token: _token);

  static final Object _token = Object();

  static FTAuthPlatformInterface _instance = MethodChannelFTAuth();

  static FTAuthPlatformInterface get instance => _instance;

  static set instance(FTAuthPlatformInterface instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Map<String, String>> login(String url) async {
    throw UnimplementedError('login has not be implemented.');
  }
}
