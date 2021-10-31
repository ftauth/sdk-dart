import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:ftauth_platform_interface/ftauth_platform_interface.dart';
import 'package:ftauth_storage_platform_interface/ftauth_storage_plugin_interface.dart';

class MethodChannelStorage extends FTAuthStoragePlatform {
  static const MethodChannel _channel =
      MethodChannel('io.ftauth.ftauth_storage');

  /// iOS-only: App group specifies where to store Keychain items and thus,
  /// which bundle IDs have access to them.
  final String? appGroup;

  MethodChannelStorage({
    this.appGroup,
  });

  @override
  Future<void> init({Uint8List? encryptionKey}) async {
    await super.init(encryptionKey: encryptionKey);
    return _channel.invokeMethod<void>('storageInit', encryptionKey);
  }

  @override
  Future<void> delete(String key) {
    return _channel.invokeMethod<void>('storageDelete', key);
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
  Future<void> setString(String key, String value) {
    return _channel.invokeMethod<void>('storageSet', <String, String>{
      'key': key,
      'value': value,
    });
  }

  @override
  Future<void> clear() {
    return _channel.invokeMethod<void>('storageClear');
  }
}
