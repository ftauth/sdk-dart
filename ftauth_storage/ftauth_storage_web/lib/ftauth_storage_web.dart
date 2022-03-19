import 'dart:async';
import 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:ftauth_storage_platform_interface/ftauth_storage_platform_interface.dart';

/// A web implementation of the ftauth_storage plugin.
class FTAuthStorageWeb extends FTAuthStoragePlatform {
  static void registerWith(Registrar registrar) {
    FTAuthStoragePlatform.instance = FTAuthStorageWeb();
  }

  @override
  Future<void> clear() {
    window.localStorage.removeWhere((key, value) => key.startsWith('ftauth.'));
    return SynchronousFuture(null);
  }

  @override
  Future<void> delete(String key) {
    window.localStorage.remove('ftauth.$key');
    return SynchronousFuture(null);
  }

  @override
  Future<String?> getString(String key) {
    return SynchronousFuture(
      window.localStorage['ftauth.$key'],
    );
  }

  @override
  Future<void> setString(String key, String value) {
    window.localStorage['ftauth.$key'] = value;
    return SynchronousFuture(null);
  }

  @override
  Future<String?> getEphemeralString(String key) {
    return SynchronousFuture(
      window.sessionStorage['ftauth.$key'],
    );
  }

  @override
  Future<void> setEphemeralString(String key, String value) {
    window.sessionStorage['ftauth.$key'] = value;
    return SynchronousFuture(null);
  }
}
