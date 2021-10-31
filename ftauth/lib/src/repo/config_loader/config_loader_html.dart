import 'package:ftauth/src/model/config/config.dart';

import 'config_loader.dart';

class ConfigLoader extends ConfigLoaderInterface {
  const ConfigLoader();

  @override
  Future<Config> fromFile(String filename) {
    throw UnimplementedError();
  }
}
