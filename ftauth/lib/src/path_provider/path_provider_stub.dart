import 'path_provider.dart';

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
