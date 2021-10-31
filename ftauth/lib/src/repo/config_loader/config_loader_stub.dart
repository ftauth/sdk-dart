import 'package:ftauth/ftauth.dart';

import 'config_loader.dart';

class ConfigLoader extends ConfigLoaderInterface {
  const ConfigLoader();

  @override
  Future<Config> fromFile(String filename) {
    throw UnimplementedError();
  }

  @override
  Future<Config> fromUrl(Uri url) {
    throw UnimplementedError();
  }
}
