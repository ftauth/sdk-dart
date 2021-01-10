abstract class PathProviderInterface {
  const PathProviderInterface();

  String? getHomeDirectory();
  String? getHiveDirectory();
}

class PathProvider extends PathProviderInterface {
  const PathProvider();

  @override
  String? getHomeDirectory() {
    throw UnimplementedError();
  }

  @override
  String? getHiveDirectory() {
    throw UnimplementedError();
  }
}
