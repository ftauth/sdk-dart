import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ftauth_flutter/ftauth_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FTAuthSecureStorage implements StorageRepo {
  FTAuthSecureStorage({
    String? appGroup,
  }) : _secureStorage = FlutterSecureStorage(
          iOptions: IOSOptions(groupId: appGroup),
        );

  final FlutterSecureStorage _secureStorage;
  late final SharedPreferences _sharedPrefs;

  @override
  Future<void> clear() => _secureStorage.deleteAll();

  @override
  Future<void> delete(String key) => _secureStorage.delete(key: key);

  @override
  Future<String?> getEphemeralString(String key) async =>
      _sharedPrefs.getString(key);

  @override
  Future<String?> getString(String key) => _secureStorage.read(key: key);

  @override
  Future<void> init({Uint8List? encryptionKey}) async {
    _sharedPrefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> setEphemeralString(String key, String value) =>
      _sharedPrefs.setString(key, value);

  @override
  Future<void> setString(String key, String value) =>
      _secureStorage.write(key: key, value: value);
}
