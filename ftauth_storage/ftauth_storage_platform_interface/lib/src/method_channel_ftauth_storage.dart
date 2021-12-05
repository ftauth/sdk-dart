import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:ftauth/ftauth.dart';

import '../ftauth_storage_platform_interface.dart';
import 'ftauth_storage.pigeon.dart';

class MethodChannelFTAuthStorage extends FTAuthStoragePlatform {
  static final NativeStorage _nativeStorage = NativeStorage();

  @override
  Future<void> clear() => _nativeStorage.clear();

  @override
  Future<void> delete(String key) => _nativeStorage.delete(key);

  @override
  Future<String?> getString(String key) async {
    try {
      return await _nativeStorage.getString(key);
    } on PlatformException catch (e) {
      FTAuth.error(e.toString());
      return null;
    }
  }

  @override
  Future<void> init({Uint8List? encryptionKey}) async {
    await super.init(encryptionKey: encryptionKey);
    FTAuth.info('encryptionKey has no effect on iOS or Android');
    return _nativeStorage.init();
  }

  @override
  Future<void> setString(String key, String value) =>
      _nativeStorage.setString(key, value);
}
