import 'package:flutter/services.dart';
import 'package:ftauth_platform_interface/ftauth_platform_interface.dart';

class MethodChannelFTAuth extends FTAuthPlatformInterface {
  static const _channel = MethodChannel('ftauth_flutter');

  @override
  Future<Map<String, String>> login(String url) async {
    final Map<String, String>? parameters =
        await _channel.invokeMapMethod<String, String>('login', url);

    if (parameters == null) {
      throw PlatformException(
        code: PlatformExceptionCodes.unknown,
        message: 'Login process failed.',
      );
    }

    return parameters;
  }
}
