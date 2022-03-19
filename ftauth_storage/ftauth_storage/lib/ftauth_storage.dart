import 'dart:async';
import 'dart:typed_data';

import 'package:ftauth/ftauth.dart';
import 'package:ftauth_storage_platform_interface/ftauth_storage_platform_interface.dart';

class FTAuthSecureStorage implements StorageRepo {
  static FTAuthStoragePlatform get _platform => FTAuthStoragePlatform.instance;

  @override
  Future<void> clear() {
    return _platform.clear();
  }

  @override
  Future<void> delete(String key) {
    return _platform.delete(key);
  }

  @override
  Future<String?> getEphemeralString(String key) {
    return _platform.getEphemeralString(key);
  }

  @override
  Future<String?> getString(String key) {
    return _platform.getString(key);
  }

  @override
  Future<void> init({
    required PathProvider pathProvider,
    Uint8List? encryptionKey,
  }) async {
    return _platform.init(
      pathProvider: pathProvider,
      encryptionKey: encryptionKey,
    );
  }

  @override
  Future<void> setEphemeralString(String key, String value) {
    return _platform.setEphemeralString(key, value);
  }

  @override
  Future<void> setString(String key, String value) {
    return _platform.setString(key, value);
  }
}

class FTAuthStorageDesktop extends FTAuthStoragePlatform {
  static void registerWith() {
    FTAuthStoragePlatform.instance = FTAuthStorageDesktop();
  }

  final _storageRepo = StorageRepo();

  @override
  Future<void> clear() {
    return _storageRepo.clear();
  }

  @override
  Future<void> delete(String key) {
    return _storageRepo.delete(key);
  }

  @override
  Future<String?> getString(String key) {
    return _storageRepo.getString(key);
  }

  @override
  Future<void> init({
    required PathProvider pathProvider,
    Uint8List? encryptionKey,
  }) async {
    await super.init(
      pathProvider: pathProvider,
      encryptionKey: encryptionKey,
    );
    return _storageRepo.init(
      pathProvider: pathProvider,
      encryptionKey: encryptionKey,
    );
  }

  @override
  Future<void> setString(String key, String value) {
    return _storageRepo.setString(key, value);
  }
}
