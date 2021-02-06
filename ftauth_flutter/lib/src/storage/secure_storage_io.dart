import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:ftauth/ftauth.dart';

class FlutterSecureStorage extends StorageRepo {
  const FlutterSecureStorage();

  static const MethodChannel _channel = const MethodChannel('ftauth_flutter');

  @override
  Future<void> deleteKey(String key) async {
    await _channel.invokeMethod<void>(
        'storageDelete', Uint8List.fromList(key.codeUnits));
  }

  @override
  Future<String?> getString(String key) async {
    final data = await _channel.invokeMethod<Uint8List?>(
        'storageGet', Uint8List.fromList(key.codeUnits));
    if (data != null) {
      return utf8.decode(data);
    }
  }

  Future<Uint8List?> getData(String key) {
    return _channel.invokeMethod<Uint8List?>(
        'storageGet', Uint8List.fromList(key.codeUnits));
  }

  @override
  Future<void> init({Uint8List? encryptionKey}) {
    return _channel.invokeMethod<void>('storageInit', encryptionKey);
  }

  @override
  Future<void> setString(String key, String value) async {
    return _channel.invokeMethod<void>('storageSet', <String, Uint8List>{
      'key': Uint8List.fromList(key.codeUnits),
      'value': Uint8List.fromList(value.codeUnits),
    });
  }
}
