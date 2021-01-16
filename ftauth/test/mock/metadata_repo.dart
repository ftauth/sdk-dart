import 'dart:convert';

import 'package:ftauth/src/jwt/keyset.dart';
import 'package:ftauth/src/metadata/metadata_repo.dart';
import 'package:ftauth/src/model/server/metadata.dart';

class MockMetadataRepo extends MetadataRepo {
  static const jwksJson = '''
  {"keys":[{"kty":"RSA","alg":"RS256","n":"3Ax2o3178fqgLNjYaLg-qbySGSr06-U3W4yvh7hPdxDLZKhP6t0QKnquzhFlJaNgnO1UrWpYRhSBKhgrxq0tqANia8fuAMQRfAVmSLKSsljaMnvEty879z2c692dIv0pFWycW8GyeGepVGnL6Ir1zi8Y9QBQqv1qTl608-e7xmFr9aksPXwpiJNsk2jIXdVSKA0ekwady5ed6sl4UOPd8kzNlRisGspjIa_AFevqLRIYG1RINt6MKiiIn64_Ld3FKXxsGsWslPfUKw3J1QKWzM2h1R90njXaiB0ljKL-6yG7FCbRXbXCS392zxdzhpYJ_PqaotD_1G4RZGQsy2ZZwQ","e":"AQAB"}]}
  ''';

  static const serverMetadataJson = '''
{"issuer":"demo","authorization_endpoint":"http://localhost:8000/authorize","token_endpoint":"http://localhost:8000/token","jwks_uri":"http://localhost:8000/jwks.json","scopes":["default","admin"],"response_types_supported":["code","token"]}
  ''';
  AuthorizationServerMetadata? _metadata;
  JsonWebKeySet? _keyStore;

  @override
  Future<JsonWebKeySet> loadKeySet() async {
    return _keyStore ??=
        JsonWebKeySet.fromJson(jsonDecode(jwksJson) as Map<String, dynamic>);
  }

  @override
  Future<AuthorizationServerMetadata> loadServerMetadata({
    bool force = false,
  }) async {
    return _metadata ??= AuthorizationServerMetadata.fromJson(
        jsonDecode(serverMetadataJson) as Map<String, dynamic>);
  }

  @override
  Future<AuthorizationServerMetadata> updateServerMetadata(
      AuthorizationServerMetadata metadata) async {
    return _metadata = metadata;
  }
}
