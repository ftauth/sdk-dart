import 'dart:async';
import 'dart:typed_data';

import 'package:ftauth/ftauth.dart';
import 'package:ftauth_storage_platform_interface/ftauth_storage_platform_interface.dart';

/// The macOS implementation of the FTAuth storage plugin.
class FTAuthStorageMacOs extends FTAuthStoragePlatform {
  static void registerWith() {
    FTAuthStoragePlatform.instance = FTAuthStorageMacOs();
  }

  static final _storageRepo = StorageRepo();

  @override
  Future<void> init({
    required PathProvider pathProvider,
    Uint8List? encryptionKey,
  }) async {
    await super.init(
      pathProvider: pathProvider,
      encryptionKey: encryptionKey,
    );
    await _storageRepo.init(
      pathProvider: pathProvider,
      encryptionKey: encryptionKey,
    );
  }

  @override
  Future<void> clear() => _storageRepo.clear();

  @override
  Future<void> delete(String key) => _storageRepo.delete(key);

  @override
  Future<String?> getString(String key) => _storageRepo.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _storageRepo.setString(key, value);
}
