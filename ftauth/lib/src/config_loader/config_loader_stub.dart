import 'package:ftauth/ftauth.dart';

import 'config_loader.dart';

class ConfigLoader extends ConfigLoaderInterface {
  @override
  Future<FTAuthConfig> fromFile(String filename) {
    throw UnimplementedError();
  }

  @override
  Future<FTAuthConfig> fromUrl(String url) {
    throw UnimplementedError();
  }
}
