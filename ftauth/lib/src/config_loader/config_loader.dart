import 'dart:convert';

import 'package:ftauth/ftauth.dart';
import 'package:ftauth/src/model/exception.dart';
import 'package:http/http.dart' as http;

export 'config_loader_stub.dart'
    if (dart.library.io) 'config_loader_io.dart'
    if (dart.library.html) 'config_loader_html.dart';

abstract class ConfigLoaderInterface {
  Future<Config> fromFile(String filename);

  Future<Config> fromUrl(String url) async {
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) {
        throw ApiException.get(url, res.statusCode, res.body);
      }
      final data = res.body;
      final json = (jsonDecode(data) as Map).cast<String, dynamic>();
      return Config.fromJson(json);
    } on http.ClientException catch (e) {
      throw ApiException.get(url, 0, e.message);
    }
  }
}
