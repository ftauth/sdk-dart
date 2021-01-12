import 'dart:convert';

import 'package:ftauth/ftauth.dart';
import 'package:http/http.dart' as http;
import 'package:jose/jose.dart';

import 'metadata_repo.dart';

class MetadataRepoImpl extends MetadataRepo {
  final FTAuthConfig _config;

  AuthorizationServerMetadata? _cached;
  JsonWebKeyStore? _keyStore;

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
  Future<JsonWebKeyStore> loadKeyStore() async {
    if (_cached == null) {
      await loadServerMetadata();
    }

    if (_keyStore == null) {
      _keyStore = JsonWebKeyStore();
      final path = '${_config.gatewayUrl}/jwks.json';
      final res = await http.get(Uri.parse(path));
      if (res.statusCode != 200) {
        throw ApiException.get(path, res.statusCode, res.body);
      }
      final json = (jsonDecode(res.body) as Map).cast<String, dynamic>();
      _keyStore!.addKeySet(JsonWebKeySet.fromJson(json));
    }

    return _keyStore!;
  }
}
