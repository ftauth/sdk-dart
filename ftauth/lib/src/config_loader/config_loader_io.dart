import 'dart:convert';
import 'dart:io';

import 'package:ftauth/ftauth.dart';

import 'config_loader.dart';

class ConfigLoader extends ConfigLoaderInterface {
  @override
  Future<FTAuthConfig> fromFile(String filename) async {
    final data = File(filename).readAsStringSync();
    final json = (jsonDecode(data) as Map).cast<String, dynamic>();
    return FTAuthConfig.fromJson(json);
  }
}
