library ftauth_storage_plugin_interface;

import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:ftauth/ftauth.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/method_channel_storage.dart';

class FTAuthStoragePlatform extends PlatformInterface implements StorageRepo {
  FTAuthStoragePlatform() : super(token: _token);

  static final Object _token = Object();

  static FTAuthStoragePlatform? _instance;

  static FTAuthStoragePlatform getInstance({String? appGroup}) {
    _instance ??= MethodChannelStorage(appGroup: appGroup);
    return _instance!;
  }

  static set instance(FTAuthStoragePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  late final SharedPreferences _ephemeralStorage;

  bool _isInitialized = false;

  @override
  @mustCallSuper
  Future<void> init({Uint8List? encryptionKey}) async {
    if (_isInitialized) {
      return;
    }
    _ephemeralStorage = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  @override
  Future<void> clear() {
    throw UnimplementedError('clear has not yet been implemented.');
  }

  @override
  Future<void> delete(String key) {
    throw UnimplementedError('delete has not yet been implemented.');
  }

  @override
  Future<String?> getString(String key) {
    throw UnimplementedError('getString has not yet been implemented.');
  }

  @override
  Future<void> setString(String key, String value) {
    throw UnimplementedError('setString has not yet been implemented.');
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
