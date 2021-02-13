import 'dart:typed_data';

import 'storage_repo_impl.dart';

abstract class StorageRepo {
  const StorageRepo();

  static final instance = StorageRepoImpl();

  Future<void> init({Uint8List? encryptionKey});
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<void> delete(String key);
  Future<void> clear();
}
