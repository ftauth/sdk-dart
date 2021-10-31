import 'dart:typed_data';

import 'storage_repo_impl.dart';

/// Handles secure storage of private information retained via the OAuth process
/// including tokens, state, and code verifiers.
abstract class StorageRepo {
  static late final instance = StorageRepoImpl();

  factory StorageRepo() {
    return instance;
  }

  /// Initializes the storage repository.
  Future<void> init({Uint8List? encryptionKey});

  /// Returns the value stored for the given key or null, if not present.
  Future<String?> getString(String key);

  /// Sets the stored value for the given key.
  Future<void> setString(String key, String value);

  /// Deletes the value associated with the given key.
  Future<void> delete(String key);

  /// Clears all values previously stored by this class. The exact values
  /// cleared depends on the configuration provided when the instance
  /// was initialized, e.g. `appGroup`.
  Future<void> clear();

  /// Stores an ephemeral value (will be removed when the app is uninstalled).
  ///
  /// On iOS, this uses UserDefaults. On Android, this uses SharedPreferences.
  Future<void> setEphemeralString(String key, String value);

  /// Retrieves an ephemeral value (will be removed when the app is uninstalled).
  ///
  /// On iOS, this uses UserDefaults. On Android, this uses SharedPreferences.
  Future<String?> getEphemeralString(String key);
}
