import 'dart:typed_data';

import 'package:ftauth/src/storage/storage_repo.dart';

class MockStorageRepo extends StorageRepo {
  late Map<String, String> _inMemStorage;

  @override
  Future<void> deleteKey(String key) async {
    _inMemStorage.remove(key);
  }

  @override
  String? getString(String key) {
    return _inMemStorage[key];
  }

  @override
  Future<void> init({Uint8List? encryptionKey}) async {
    _inMemStorage = {};
  }

  @override
  Future<void> setString(String key, String value) async {
    _inMemStorage[key] = value;
  }

  void clear() {
    _inMemStorage = {};
  }
}
