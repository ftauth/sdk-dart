library ftauth_storage_platform_interface;

import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:ftauth/ftauth.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/method_channel_ftauth_storage.dart';

export 'src/method_channel_ftauth_storage.dart';

abstract class FTAuthStoragePlatform extends PlatformInterface
    implements StorageRepo {
  FTAuthStoragePlatform() : super(token: _token);

  static final Object _token = Object();

  static FTAuthStoragePlatform _instance = MethodChannelFTAuthStorage();

  static FTAuthStoragePlatform get instance => _instance;

  static set instance(FTAuthStoragePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  late SharedPreferences _sharedPrefs;

  @override
  Future<void> clear() => throw UnimplementedError();

  @override
  Future<void> delete(String key) => throw UnimplementedError();

  @override
  Future<String?> getEphemeralString(String key) =>
      SynchronousFuture(_sharedPrefs.getString(key));

  @override
  Future<String?> getString(String key) => throw UnimplementedError();

  @override
  @mustCallSuper
  Future<void> init({Uint8List? encryptionKey}) async {
    _sharedPrefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> setEphemeralString(String key, String value) =>
      _sharedPrefs.setString(key, value);

  @override
  Future<void> setString(String key, String value) =>
      throw UnimplementedError();
}
