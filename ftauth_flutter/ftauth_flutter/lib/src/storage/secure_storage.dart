import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:ftauth/ftauth.dart';
import 'package:ftauth_platform_interface/ftauth_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlutterSecureStorage extends StorageRepo {
  // TODO: Add pigeon for IOSOptions
  static const _iosKeychainService = 'io.ftauth.ftauth';
  static const MethodChannel _channel = const MethodChannel('ftauth_flutter');

  late final SharedPreferences _ephemeralStorage;

  /// iOS-only: App group specifies where to store Keychain items and thus,
  /// which bundle IDs have access to them.
  final String? appGroup;

  FlutterSecureStorage({
    this.appGroup,
  });

  @override
  Future<void> init({Uint8List? encryptionKey}) async {
    _ephemeralStorage = await SharedPreferences.getInstance();
    return _channel.invokeMethod<void>('storageInit', encryptionKey);
  }

  @override
  Future<void> delete(String key) async {
    await _channel.invokeMethod<void>('storageDelete', key);
  }

  @override
  Future<String?> getString(String key) async {
    final data = await getData(key);
    if (data == null) {
      return null;
    }
    return utf8.decode(data);
  }

  Future<Uint8List?> getData(String key) async {
    try {
      return await _channel.invokeMethod<Uint8List?>('storageGet', key);
    } on PlatformException catch (e) {
      if (e.code == PlatformExceptionCodes.keyNotFound) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<void> setString(String key, String value) async {
    return _channel.invokeMethod<void>('storageSet', <String, String>{
      'key': key,
      'value': value,
    });
  }

  @override
  Future<void> clear() {
    return _channel.invokeMethod<void>('storageClear');
  }

  @override
  Future<String?> getEphemeralString(String key) async {
    return _ephemeralStorage.getString(key);
  }

  @override
  Future<void> setEphemeralString(String key, String value) async {
    await _ephemeralStorage.setString(key, value);
  }
}
