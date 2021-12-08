import 'dart:convert';
import 'dart:io';

import 'package:ftauth/ftauth.dart';

import 'config_loader.dart';

class ConfigLoader extends ConfigLoaderInterface {
  const ConfigLoader();

  @override
  Future<Config> fromFile(String filename) async {
    final data = await File(filename).readAsString();
    final json = (jsonDecode(data) as Map).cast<String, Object?>();
    return Config.fromJson(json);
  }
}
