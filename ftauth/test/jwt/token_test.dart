import 'dart:convert';
import 'dart:typed_data';

import 'package:ftauth/src/jwt/alg.dart';
import 'package:ftauth/src/jwt/claims.dart';
import 'package:ftauth/src/jwt/header.dart';
import 'package:ftauth/src/jwt/key.dart';
import 'package:ftauth/src/jwt/token.dart';
import 'package:ftauth/src/jwt/type.dart';
import 'package:ftauth/src/jwt/util.dart';
import 'package:ftauth/src/crypto/crypto_key.dart';
import 'package:test/test.dart';

class _TestCase {
  final String json;
  final JsonWebToken token;
  final String key;

  _TestCase({
    required this.json,
    required this.token,
    required this.key,
  });
}

void main() {
  group('JsonWebToken', () {
    final tests = <_TestCase>[
      () {
        final raw =
            'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjEzMDA4MTkzODAsImh0dHA6Ly9leGFtcGxlLmNvbS9pc19yb290Ijp0cnVlLCJpc3MiOiJqb2UifQ.LGyv4nF987S4V9z9qm-803XzhHTFe0o82-JsLGEZCjQ';
        return _TestCase(
          json: raw,
          token: JsonWebToken(
            raw: raw,
            header: JsonWebHeader(
              type: TokenType.JWT,
              algorithm: Algorithm.HMACSHA256,
            ),
            claims: JsonWebClaims(
              issuer: 'joe',
              expiration: DateTime.fromMillisecondsSinceEpoch(1300819380),
              customClaims: {
                'http://example.com/is_root': true,
              },
            ),
            signature: base64RawUrl
                .decode('LGyv4nF987S4V9z9qm-803XzhHTFe0o82-JsLGEZCjQ'),
          ),
          key: '''{
					"kty": "oct",
					"k": "AyM1SysPpbyDfgZld3umj1qzKObwVMkoqQ-EstJQLr_T-1qS0gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr1Z9CAow"
				}''',
        );
      }(),
    ];

    for (var i = 0; i < tests.length; i++) {
      test('parse $i', () {
        final token = JsonWebToken.parse(tests[i].json);
        final expected = tests[i].token;
        expect(token, expected);
      });

      test('encode $i', () async {
        final jwk = JsonWebKey.fromJson(jsonDecode(tests[i].key));
        final jwt = await tests[i].token.encodeBase64(jwk.privateKey!);
        expect(jwt, tests[i].json);
      });
    }
  });
}
