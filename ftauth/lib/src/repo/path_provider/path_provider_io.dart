import 'dart:io';

import 'package:path/path.dart' as path;

import 'path_provider.dart';

class PathProvider extends PathProviderInterface {
  const PathProvider();

  @override
  String? getHomeDirectory() {
    String? home;
    final envVars = Platform.environment;
    if (Platform.isMacOS) {
      home = envVars['HOME'];
    } else if (Platform.isLinux) {
      home = envVars['HOME'];
    } else if (Platform.isWindows) {
      home = envVars['UserProfile'];
    }
    return home;
  }

  @override
  String? getHiveDirectory() {
    final homePath = getHomeDirectory();
    if (homePath == null) {
      return null;
    }
    final hivePath = path.join(homePath, '.ftauth');
    final hiveDir = Directory(hivePath);
    if (!hiveDir.existsSync()) {
      hiveDir.createSync(recursive: false);
    }
    return hivePath;
  }
}
