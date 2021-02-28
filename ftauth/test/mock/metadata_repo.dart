import 'dart:convert';

import 'package:ftauth/src/jwt/keyset.dart';
import 'package:ftauth/src/metadata/metadata_repo.dart';
import 'package:ftauth/src/model/server/metadata.dart';

class MockMetadataRepo extends MetadataRepo {
  static const jwksJson = '''
  {
    "keys": [
        {
            "kty": "RSA",
            "use": "sig",
            "key_ops": [
                "verify"
            ],
            "alg": "PS256",
            "kid": "318a4ed6-f73e-447f-a65f-fec5f30e4dbe",
            "n": "6u4pJrjCBuQZr9hji5yBSwYYJDDxr2Cmlc1DarYCtLPVUTOHC3E3aQ2tc1Y3M5k4QxZfxeseCaUTi_VwYRTgfJpgEn-fwIA7_ofLwwD65bHHTz0JDjYNx2Kmxh9iQDDVJQi9vSm7bn1GBQuXAMvFaV1-vwpmRRo-QegTLQNp4rN76PDsp8a9_XF27JnrfLV7ewkI8wT_kIk5W3CEFMqnsiHdIUwt8XmG4XLw9lvHzJF0jZIfh-SHYbsrnE5YD4hOQZeF2mAWmIReBKMRIeb3D16foJz5-TY08fGXF7sFscHIFkErP7se-ujXFo14o_BRzVsyjbU-tTX4yKQjcbH4IZNIoUzZ1QgrwagJKgc7RAzmqPBKfKF749GY2e0BBhnh5JCExeYUZRduM77Gv1eFsJS_TsVQ82c0tpQe6wzpXwouDv5raem95bY4tJkOJDdqQ69HdWeJjbXMp8hVx2dvqfODyTRsI7LwmB4rTQmtjxHabdt0YNRC9iU0qc5TJFqj",
            "e": "AQAB"
        },
        {
            "kty": "EC",
            "use": "sig",
            "key_ops": [
                "verify"
            ],
            "alg": "ES256",
            "kid": "eea79918-47f9-40a9-bc3c-97fecde71081",
            "crv": "P-256",
            "x": "YYlOiAJR0Xjm_tnO1EL9s7N8V-_xtRxRZtvHJdDTbRk",
            "y": "pSDpQtdCEdLPoA8V35E470kjf4QAfWLEf11ScE1UYmo"
        },
        {
            "kty": "RSA",
            "use": "sig",
            "key_ops": [
                "verify"
            ],
            "alg": "RS256",
            "kid": "83c182e4-f969-4789-bea6-16940dd75e91",
            "n": "6u4pJrjCBuQZr9hji5yBSwYYJDDxr2Cmlc1DarYCtLPVUTOHC3E3aQ2tc1Y3M5k4QxZfxeseCaUTi_VwYRTgfJpgEn-fwIA7_ofLwwD65bHHTz0JDjYNx2Kmxh9iQDDVJQi9vSm7bn1GBQuXAMvFaV1-vwpmRRo-QegTLQNp4rN76PDsp8a9_XF27JnrfLV7ewkI8wT_kIk5W3CEFMqnsiHdIUwt8XmG4XLw9lvHzJF0jZIfh-SHYbsrnE5YD4hOQZeF2mAWmIReBKMRIeb3D16foJz5-TY08fGXF7sFscHIFkErP7se-ujXFo14o_BRzVsyjbU-tTX4yKQjcbH4IZNIoUzZ1QgrwagJKgc7RAzmqPBKfKF749GY2e0BBhnh5JCExeYUZRduM77Gv1eFsJS_TsVQ82c0tpQe6wzpXwouDv5raem95bY4tJkOJDdqQ69HdWeJjbXMp8hVx2dvqfODyTRsI7LwmB4rTQmtjxHabdt0YNRC9iU0qc5TJFqj",
            "e": "AQAB"
        }
    ]
  }
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
