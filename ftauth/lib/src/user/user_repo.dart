import 'dart:convert';

import 'package:ftauth/ftauth.dart';
import 'package:ftauth/src/model/user/user.dart';
import 'package:http/http.dart' as http;

class UserRepo {
  final FTAuthConfig _config;
  final http.Client _client;

  const UserRepo(this._config, this._client);

  Future<User> getUserInfo(String userId) async {
    final endpoint = _config.gatewayUrl.replace(
      path: _config.gatewayUrl.path + '/user',
    );
    try {
      final resp = await _client.get(endpoint);
      if (resp.statusCode != 200) {
        throw ApiException.get(endpoint.toString(), resp.statusCode);
      }
      final json = jsonDecode(resp.body) as Map;
      return User.fromJson(json.cast());
    } on http.ClientException catch (e) {
      throw ApiException.get(endpoint.toString(), 0, e.toString());
    }
  }
}
