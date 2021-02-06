import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:ftauth/ftauth.dart';

class FlutterAuthorizer extends Authorizer {
  FlutterAuthorizer(FTAuthConfig config) : super(config);

  @override
  Future<void> launchUrl(String url) async {
    if (await canLaunch(url) || _platformOverride) {
      await launch(url, webOnlyWindowName: '_self');
    }
  }

  /// `canLaunch` will return `false` on Android if incorrectly configured.
  ///
  // TODO: Fix Android.
  bool get _platformOverride {
    // Do not import dart:io on Web
    if (kIsWeb) return false;
    return Platform.isAndroid;
  }
}
