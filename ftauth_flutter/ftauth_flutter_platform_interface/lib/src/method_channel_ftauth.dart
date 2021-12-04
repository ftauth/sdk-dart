import 'dart:io';

import 'package:flutter/services.dart';
import 'package:ftauth/ftauth.dart';
import 'package:ftauth_flutter_platform_interface/ftauth_flutter_platform_interface.dart';
import 'package:url_launcher/url_launcher.dart';

class MethodChannelFTAuth extends FTAuthPlatformInterface {
  static const _channel = MethodChannel('ftauth_flutter');

  @override
  Future<void> launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Future<void> login({
    String? language,
    String? countryCode,
  }) async {
    if (Platform.isLinux || Platform.isWindows || Platform.isFuchsia) {
      return super.login(language: language, countryCode: countryCode);
    }
    final url = await authorize(
      language: language,
      countryCode: countryCode,
    );

    FTAuth.debug('Launching url: $url');
    final Map<String, String>? parameters =
        await _channel.invokeMapMethod<String, String>('login', url);

    if (parameters == null) {
      throw PlatformException(
        code: PlatformExceptionCodes.unknown,
        message: 'Login process failed.',
      );
    }

    await exchange(parameters);
  }
}
