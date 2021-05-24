import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:ftauth_jwt/ftauth_jwt.dart';
import 'package:test/test.dart';

import 'data/data.g.dart';

void main() {
  EquatableConfig.stringify = true;

  group('JsonWebToken', () {
    final jwks = JsonWebKeySet.fromJson(jsonDecode(keySet));
    for (final testCase in testCases) {
      final alg = testCase.algorithm;
      late JsonWebToken token;
      late JsonWebKey privateKey;
      late JsonWebKey publicKey;
      test('parse ${alg.code}', () {
        try {
          token = JsonWebToken.parse(testCase.jwt);
          privateKey = JsonWebKey.fromJson(jsonDecode(testCase.privateJwk));
          publicKey = JsonWebKey.fromJson(jsonDecode(testCase.publicJwk));
        } catch (e) {
          fail(e.toString());
        }
      });

      late String encoded;
      test('sign ${alg.code}', () async {
        encoded = await token.encodeBase64(privateKey.signer);
        if (alg.keyType != KeyType.EllipticCurve) {
          expect(encoded, testCase.jwt);
        }
      });

      test('verify ${alg.code}', () async {
        // Verify original JWT
        await expectLater(
          token.verifyWithKeySet(
            jwks,
            verifierFactory: (key) => key.verifier,
          ),
          completes,
        );
        await expectLater(
          token.verify(publicKey),
          completes,
        );

        // Verify generated JWT
        final encodedJwt = JsonWebToken.parse(encoded);
        await expectLater(
          encodedJwt.verifyWithKeySet(
            jwks,
            verifierFactory: (key) => key.verifier,
          ),
          completes,
        );
        await expectLater(
          encodedJwt.verify(publicKey),
          completes,
        );
      });
    }
  });
}
