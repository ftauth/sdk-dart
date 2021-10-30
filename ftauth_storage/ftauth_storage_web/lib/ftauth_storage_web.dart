import 'dart:async';
import 'dart:html' as html show window;

import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:ftauth_storage_platform_interface/ftauth_storage_plugin_interface.dart';

/// A web implementation of the FtauthStorageWeb plugin.
class FTAuthStorageWeb extends FTAuthStoragePlatform {
  static void registerWith(Registrar registrar) {
    FTAuthStoragePlatform.instance = FTAuthStorageWeb();
  }

  @override
  Future<void> clear() {
    html.window.localStorage
        .removeWhere((key, value) => key.startsWith('ftauth.'));
    return SynchronousFuture(null);
  }

  @override
  Future<void> delete(String key) {
    html.window.localStorage.remove('ftauth.$key');
    return SynchronousFuture(null);
  }

  @override
  Future<String?> getString(String key) {
    return SynchronousFuture(
      html.window.localStorage['ftauth.$key'],
    );
  }

  @override
  Future<void> setString(String key, String value) {
    html.window.localStorage['ftauth.$key'] = value;
    return SynchronousFuture(null);
  }
}
