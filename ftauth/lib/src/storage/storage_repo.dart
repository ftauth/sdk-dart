import 'dart:typed_data';

import 'storage_repo_impl.dart';

abstract class StorageRepo {
  static final instance = StorageRepoImpl();

  Future<void> init({Uint8List? encryptionKey});
  String? getString(String key);
  Future<void> setString(String key, String value);
  Future<void> deleteKey(String key);
}
