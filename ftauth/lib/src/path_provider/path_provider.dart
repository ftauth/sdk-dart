abstract class PathProviderInterface {
  String? getHomeDirectory();
  String? getHiveDirectory();
}

class PathProvider extends PathProviderInterface {
  @override
  String? getHomeDirectory() {
    throw UnimplementedError();
  }

  @override
  String? getHiveDirectory() {
    throw UnimplementedError();
  }
}
