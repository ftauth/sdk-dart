import 'dart:html' as html show window;

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:ftauth_platform_interface/ftauth_platform_interface.dart';

/// A web implementation of the FtauthFlutter plugin.
class FTAuthFlutterWeb extends FTAuthPlatformInterface {
  static void registerWith(Registrar registrar) {
    FTAuthPlatformInterface.instance = FTAuthFlutterWeb();
  }

  @override
  Future<Map<String, String>> login(String url) async {
    html.window.open(url, '_self');
    throw PlatformException(
      code: PlatformExceptionCodes.couldNotLaunchWebview,
      message: 'Could not launch webview',
    );
  }
}
