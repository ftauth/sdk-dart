import 'package:pigeon/pigeon.dart';

@HostApi()
abstract class NativeStorage {
  void clear();

  void delete(String key);

  String getString(String key);

  void init();

  void setString(String key, String value);
}
