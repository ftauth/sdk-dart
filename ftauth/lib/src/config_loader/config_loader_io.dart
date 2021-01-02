import 'dart:convert';
import 'dart:io';

import 'package:ftauth/ftauth.dart';

import 'config_loader_stub.dart';

class ConfigLoader extends ConfigLoaderStub {
  @override
  Future<Config> fromFile(String filename) async {
    final data = File(filename).readAsStringSync();
    final json = (jsonDecode(data) as Map).cast<String, dynamic>();
    return Config.fromJson(json);
  }
}
