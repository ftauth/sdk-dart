import 'dart:convert';

import 'package:ftauth/ftauth.dart';
import 'package:ftauth/src/jwt/keyset.dart';
import 'package:http/http.dart' as http;

import 'metadata_repo.dart';

class MetadataRepoImpl extends MetadataRepo {
  final FTAuthConfig _config;

  AuthorizationServerMetadata? _cached;
  JsonWebKeySet? _keySet;

  MetadataRepoImpl(this._config);

  @override
  Future<AuthorizationServerMetadata> loadServerMetadata({
    bool force = false,
  }) async {
    if (_cached == null || force) {
      final path =
          '${_config.gatewayUrl}/.well-known/oauth-authorization-server';
      final res = await http.get(Uri.parse(path));
      if (res.statusCode != 200) {
        throw ApiException.get(path, res.statusCode, res.body);
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
    final res = await http.put(Uri.parse(path), body: metadata.toJson());
    if (res.statusCode != 200) {
      throw ApiException.put(path, res.statusCode, res.body);
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
      final res = await http.get(Uri.parse(path));
      if (res.statusCode != 200) {
        throw ApiException.get(path, res.statusCode, res.body);
      }
      final json = (jsonDecode(res.body) as Map).cast<String, dynamic>();
      _keySet = JsonWebKeySet.fromJson(json);
    }

    return _keySet!;
  }
}
