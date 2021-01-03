import 'dart:typed_data';

import 'package:hive/hive.dart';

import 'storage_repo.dart';

class StorageRepoImpl extends StorageRepo {
  late Box<String> _box;

  Future<void> init({
    Uint8List? encryptionKey,
  }) async {
    _box = await Hive.openBox<String>(
      'ftoauth',
      encryptionCipher:
          encryptionKey != null ? HiveAesCipher(encryptionKey) : null,
    );
  }

  @override
  String getString(String key) {
    return _box.get(key);
  }

  @override
  Future<void> setString(String key, String value) {
    return _box.put(key, value);
  }

  @override
  Future<void> deleteKey(String key) {
    return _box.delete(key);
  }
}
