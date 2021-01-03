abstract class StorageRepo {
  String getString(String key);
  Future<void> setString(String key, String value);
  Future<void> deleteKey(String key);
}
