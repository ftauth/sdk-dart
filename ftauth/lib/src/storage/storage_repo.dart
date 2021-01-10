abstract class StorageRepo {
  const StorageRepo();

  String? getString(String key);
  Future<void> setString(String key, String value);
  Future<void> deleteKey(String key);
}
