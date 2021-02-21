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
        "alg": "PS256",
        "n": "3Ie9ws9wol7CvsePFUB3GW4If3uaj2JryX6p4fA0-sgZ63XCMb0ZSFXc0vbdThK71n0THFBjPsEuRUdjzcN26rlPxud0spWbSiAUdEzv7BLg1cKjzI2zWhFyZeci5GQALx-xkd04_x92TkbFt1t-xLH2DcQCLJ7iE6ezmLvdCI9QYqKq9vpesAehZKnCGHDA3ctPec__q-cC9flnr7Oi39ksMxNG-ECXCkB31Lpflr77YhLH5W6xKj8Q6FzE_YfbcN6It1FAqBIgeS9N8kQk_CJluxtPLJkZRQjmGq8SBpTcbaMZ_27XOUaZDD-aDcuddSPNN7W3g1w1NDbTRMKduoKr8VB7YDrCj2ywZAl9w_v_SS3OED16gI6t1EBBgxIp9ljnBd4vH37y7CTPpZOcKaheXV6Lp_bPCm8mFjzG4u2JoY1Mnfw0uvcP70VJm68-xa9yw8bdW7QsQ5tl8Ehyy9ea-XQmtmFoWUdGlrE6ZlNMQOmlW57BEXRmmpsZ4z9pHGHBQevAFb7ltIu0dQzyrtf7f7afzglIWIiRpcy_9rszXa-EykxKKf2FwQ84godmzWtpfKHJFy1MoKo_ZncMSUwlM3hnurBQMJ8pqhANQltCNK1MF4xFK2p-_BrDi2DdVQ0Bgu16w9E0dO26g1_osCXO3zi565pWfV8sEoSujRc",
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
