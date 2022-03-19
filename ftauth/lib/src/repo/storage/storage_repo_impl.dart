import 'dart:typed_data';

import 'package:ftauth/src/repo/path_provider/path_provider.dart';
import 'package:hive/hive.dart';

import 'storage_repo.dart';

class StorageRepoImpl implements StorageRepo {
  late Box<String> _box;

  @override
  Future<void> init({
    required PathProvider pathProvider,
    Uint8List? encryptionKey,
  }) async {
    final path = pathProvider.getHiveDirectory();
    _box = await Hive.openBox<String>(
      'ftauth',
      path: path,
      encryptionCipher:
          encryptionKey != null ? HiveAesCipher(encryptionKey) : null,
    );
  }

  @override
  Future<String?> getString(String key) async {
    return _box.get(key);
  }

  @override
  Future<void> setString(String key, String value) {
    return _box.put(key, value);
  }

  @override
  Future<void> delete(String key) {
    return _box.delete(key);
  }

  @override
  Future<void> clear() {
    return _box.clear();
  }

  @override
  Future<String?> getEphemeralString(String key) {
    // TODO: implement getEphemeralString
    return getString(key);
  }

  @override
  Future<void> setEphemeralString(String key, String value) {
    // TODO: implement setEphemeralString
    return setString(key, value);
  }
}
