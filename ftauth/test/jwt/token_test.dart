import 'dart:convert';

import 'package:equatable/equatable.dart';
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
  final String? key;

  _TestCase({
    required this.json,
    required this.token,
    required this.key,
  });
}

void main() {
  EquatableConfig.stringify = true;

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
              expiration:
                  DateTime.fromMillisecondsSinceEpoch(1300819380 * 1000),
              customClaims: {
                'http://example.com/is_root': true,
              },
            ),
            signature: symmetricKeyFromJson(
                'LGyv4nF987S4V9z9qm-803XzhHTFe0o82-JsLGEZCjQ'),
          ),
          key: '''{
					"kty": "oct",
					"k": "AyM1SysPpbyDfgZld3umj1qzKObwVMkoqQ-EstJQLr_T-1qS0gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr1Z9CAow"
				}''',
        );
      }(),
      // () {
      //   final raw =
      //       'eyJ0eXAiOiJhdCtqd3QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIzY2Y5YTdhYy05MTk4LTQ2OWUtOTJhNy1jYzJmMTVkOGI4N2QiLCJjbGllbnRfaWQiOiIzY2Y5YTdhYy05MTk4LTQ2OWUtOTJhNy1jYzJmMTVkOGI4N2QiLCJleHAiOjE2MTI0Njk5MDcsImlhdCI6MTYxMjQ2NjMwNywiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo4MDgwIiwianRpIjoiODg4MmNiMGMtNmY1ZS00OGU3LThiZWUtNWFiNDBiNTZmZDMyIiwic2NvcGUiOiJhZG1pbiBkZWZhdWx0Iiwic3ViIjoiQWRtaW4iLCJ1c2VySW5mbyI6eyJpZCI6IkFkbWluIn19.bAVKdzNLEJLK837Rghgusf8Q77hRXiuFguAIfUoZOwQ9ZubZ94rNTTC_j0B_VXTeOSmn3Ma_iJaols2xpN-Z5TMnZzKW5ECk8HsI3LayTE84j-XN32eRZuPkAoqZX4-X0Ri-rlS8w2y59kPYqotWrHcHfczv4eAqaR4GUI-su7I7jlDUkdbdkdwwkenlehsCU9xPRd_Tkqj-qmc0EFsXs1lIhgj2EylAIaib8yiGxuQ-Ebe3pNeBe4HOxLwEEY4EpL_JXxjUtn4PsMH2Gv-dGGk6hZhtd2qJooI-lyh4BG-2OW1l2-XrpzulFHgbKwwbTepFCfu82iJhXzivK-SZOANt-fCmtRrIbVPN50d_otKuc9JYvbRdxttEuMNGHTf_EFPS8DefVsbPCFCLPwkST9ugOPxYV1sB8OFTjx0RHQFu8dJafUUCqb7WIjcvHTDzLbQGY72dBB6YHb5ITJ1H7bOr4HQlkvAjx4-9W9p6AxppKu1AwzO2JVQZFiqQTbBltyCbPNif0yXxrzvSZFzKZHZtaPwjk9DOTnpU40Bu6TGNPOBfQH2xtSVJXIME30JVuq58Mta0VZR7DvEYpEo4u0V7d9KJKdGSjqt1ceYX1NiQoXeV9-TaooULMqy-3l1xh-UdOwzY5cWB803_V_0tjiXaxBRAwh7FE9G6qvLGSgM';
      //   return _TestCase(
      //     json: raw,
      //     token: JsonWebToken(
      //       header: JsonWebHeader(
      //         type: TokenType.Access,
      //         algorithm: Algorithm.RSASHA256,
      //       ),
      //       claims: JsonWebClaims(
      //         audience: '3cf9a7ac-9198-469e-92a7-cc2f15d8b87d',
      //         clientId: '3cf9a7ac-9198-469e-92a7-cc2f15d8b87d',
      //         expiration:
      //             DateTime.fromMillisecondsSinceEpoch(1612469907 * 1000),
      //         issuedAt: DateTime.fromMillisecondsSinceEpoch(1612466307 * 1000),
      //         issuer: 'http://localhost:8080',
      //         jwtId: '8882cb0c-6f5e-48e7-8bee-5ab40b56fd32',
      //         scope: 'admin default',
      //         subject: 'Admin',
      //         userInfo: <String, dynamic>{
      //           'id': 'Admin',
      //         },
      //       ),
      //       signature: base64RawUrl.decode(
      //           'bAVKdzNLEJLK837Rghgusf8Q77hRXiuFguAIfUoZOwQ9ZubZ94rNTTC_j0B_VXTeOSmn3Ma_iJaols2xpN-Z5TMnZzKW5ECk8HsI3LayTE84j-XN32eRZuPkAoqZX4-X0Ri-rlS8w2y59kPYqotWrHcHfczv4eAqaR4GUI-su7I7jlDUkdbdkdwwkenlehsCU9xPRd_Tkqj-qmc0EFsXs1lIhgj2EylAIaib8yiGxuQ-Ebe3pNeBe4HOxLwEEY4EpL_JXxjUtn4PsMH2Gv-dGGk6hZhtd2qJooI-lyh4BG-2OW1l2-XrpzulFHgbKwwbTepFCfu82iJhXzivK-SZOANt-fCmtRrIbVPN50d_otKuc9JYvbRdxttEuMNGHTf_EFPS8DefVsbPCFCLPwkST9ugOPxYV1sB8OFTjx0RHQFu8dJafUUCqb7WIjcvHTDzLbQGY72dBB6YHb5ITJ1H7bOr4HQlkvAjx4-9W9p6AxppKu1AwzO2JVQZFiqQTbBltyCbPNif0yXxrzvSZFzKZHZtaPwjk9DOTnpU40Bu6TGNPOBfQH2xtSVJXIME30JVuq58Mta0VZR7DvEYpEo4u0V7d9KJKdGSjqt1ceYX1NiQoXeV9-TaooULMqy-3l1xh-UdOwzY5cWB803_V_0tjiXaxBRAwh7FE9G6qvLGSgM'),
      //     ),
      //     key: null,
      //   );
      // }(),
    ];

    for (var i = 0; i < tests.length; i++) {
      test('parse $i', () {
        final token = JsonWebToken.parse(tests[i].json);
        final expected = tests[i].token;
        expect(token, expected);
      });

      if (tests[i].key != null) {
        test('encode $i', () async {
          final jwk = JsonWebKey.fromJson(jsonDecode(tests[i].key!));
          final jwt = await tests[i].token.encodeBase64(jwk.signer);
          expect(jwt, tests[i].json);
        });
      } else {
        test('encode unsigned $i', () async {
          final jwt = tests[i].token.encodeUnsigned();
          expect(jwt, tests[i].json.split('.').sublist(0, 2).join('.'));
        });
      }
    }
  });
}
