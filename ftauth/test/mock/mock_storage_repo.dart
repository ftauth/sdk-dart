import 'dart:typed_data';

import 'package:ftauth/ftauth.dart';

class MockStorageRepo extends StorageRepo {
  Map<String, String> _inMemStorage = {};

  @override
  Future<void> delete(String key) async {
    _inMemStorage.remove(key);
  }

  @override
  Future<String?> getString(String key) async {
    return _inMemStorage[key];
  }

  @override
  Future<void> setString(String key, String value) async {
    _inMemStorage[key] = value;
  }

  @override
  Future<void> clear() async {
    _inMemStorage = {};
  }

  @override
  Future<String?> getEphemeralString(String key) async {
    return _inMemStorage[key];
  }

  @override
  Future<void> setEphemeralString(String key, String value) async {
    _inMemStorage[key] = value;
  }

  @override
  Future<void> init({Uint8List? encryptionKey}) async {}
}
