import 'dart:convert';

import 'package:ftauth/ftauth.dart';
import 'package:ftauth_jwt/ftauth_jwt.dart';
import 'package:http/http.dart' as http;

class MetadataRepoImpl implements MetadataRepo {
  final Config _config;
  final http.Client _httpClient;

  AuthorizationServerMetadata? _cached;
  JsonWebKeySet? _keySet;

  MetadataRepoImpl(this._config, this._httpClient);

  @override
  Future<AuthorizationServerMetadata> loadServerMetadata({
    bool force = false,
  }) async {
    if (_cached == null || force) {
      final path =
          '${_config.gatewayUrl}/.well-known/oauth-authorization-server';
      final uri = Uri.parse(path);
      final res = await _httpClient.get(uri);
      if (res.statusCode != 200) {
        throw ApiException.get(uri, res.statusCode, res.body);
      } else {
        final jsonBody = (json.decode(res.body) as Map).cast<String, dynamic>();
        _cached = AuthorizationServerMetadata.fromJson(jsonBody);
      }
    }
    return _cached!;
  }

  @override
  Future<AuthorizationServerMetadata> updateServerMetadata(
    AuthorizationServerMetadata metadata,
  ) async {
    final path = '${_config.gatewayUrl}/.well-known/oauth-authorization-server';
    final uri = Uri.parse(path);
    final res = await _httpClient.put(uri, body: metadata.toJson());
    if (res.statusCode != 200) {
      throw ApiException.put(uri, res.statusCode, res.body);
    } else {
      final jsonBody = (json.decode(res.body) as Map).cast<String, dynamic>();
      _cached = AuthorizationServerMetadata.fromJson(jsonBody);
    }
    return _cached!;
  }

  @override
  Future<JsonWebKeySet> loadKeySet() async {
    if (_cached == null) {
      await loadServerMetadata();
    }

    if (_keySet == null) {
      final path = '${_config.gatewayUrl}/jwks.json';
      final uri = Uri.parse(path);
      try {
        final res = await _httpClient.get(uri);
        if (res.statusCode != 200) {
          throw ApiException.get(uri, res.statusCode, res.body);
        }
        final json = (jsonDecode(res.body) as Map).cast<String, dynamic>();
        _keySet = JsonWebKeySet.fromJson(json);
      } on http.ClientException catch (e) {
        throw ApiException.get(uri, 0, e.toString());
      }
    }

    return _keySet!;
  }
}
