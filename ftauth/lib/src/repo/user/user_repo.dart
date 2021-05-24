import 'dart:convert';

import 'package:ftauth/ftauth.dart';
import 'package:ftauth/src/authorizer/keys.dart';
import 'package:http/http.dart' as http;

abstract class UserRepoInterface {
  Future<User> getUserInfo();
}

class UserRepo implements UserRepoInterface {
  final Config _config;
  final Client _client;
  final StorageRepo _storageRepo;

  const UserRepo(this._config, this._client, this._storageRepo);

  @override
  Future<User> getUserInfo() async {
    final cachedInfo = await _storageRepo.getString(keyUserInfo);
    if (cachedInfo != null) {
      return User.fromJson(jsonDecode(cachedInfo));
    }
    final endpoint = _config.userInfoUri;
    try {
      final resp = await _client.get(endpoint);
      if (resp.statusCode != 200) {
        throw ApiException.get(endpoint, resp.statusCode, resp.body);
      }
      await _storageRepo.setString(keyUserInfo, resp.body);
      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      return User.fromJson(json);
    } on http.ClientException catch (e) {
      throw ApiException.get(endpoint, 0, e.toString());
    }
  }
}
