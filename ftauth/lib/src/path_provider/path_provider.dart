export 'path_provider_stub.dart'
    if (dart.library.io) 'path_provider_io.dart'
    if (dart.library.html) 'path_provider_html.dart';

abstract class PathProviderInterface {
  const PathProviderInterface();

  String? getHomeDirectory();
  String? getHiveDirectory();
}
