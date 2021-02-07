import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:ftauth/ftauth.dart';

class FlutterSecureStorage extends StorageRepo {
  const FlutterSecureStorage._();

  static const instance = FlutterSecureStorage._();
  static const MethodChannel _channel = const MethodChannel('ftauth_flutter');

  @override
  Future<void> deleteKey(String key) async {
    await _channel.invokeMethod<void>('storageDelete', key);
  }

  @override
  Future<String?> getString(String key) async {
    final data = await _channel.invokeMethod<Uint8List?>('storageGet', key);
    if (data != null) {
      return utf8.decode(data);
    }
  }

  Future<Uint8List?> getData(String key) {
    return _channel.invokeMethod<Uint8List?>('storageGet', key);
  }

  @override
  Future<void> init({Uint8List? encryptionKey}) {
    return _channel.invokeMethod<void>('storageInit', encryptionKey);
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
}
