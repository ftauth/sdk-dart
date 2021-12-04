import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:ftauth_flutter_platform_interface/ftauth_flutter_platform_interface.dart';

/// A web implementation of the FtauthFlutter plugin.
class FTAuthFlutterWeb extends FTAuthPlatformInterface {
  static void registerWith(Registrar registrar) {
    FTAuthPlatformInterface.instance = FTAuthFlutterWeb();
  }
}
