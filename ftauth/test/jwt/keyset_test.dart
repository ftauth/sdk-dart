import 'dart:convert';

import 'package:ftauth/src/jwt/alg.dart';
import 'package:ftauth/src/jwt/ecdsa.dart';
import 'package:ftauth/src/jwt/key.dart';
import 'package:ftauth/src/jwt/key_type.dart';
import 'package:ftauth/src/jwt/key_use.dart';
import 'package:ftauth/src/jwt/keyset.dart';
import 'package:ftauth/src/jwt/util.dart';
import 'package:test/test.dart';

class _TestCase {
  final String jwks;
  final JsonWebKeySet keySet;

  _TestCase({required this.keySet, required this.jwks});
}

void main() {
  group('JsonWebKeySet', () {
    final tests = <_TestCase>[
      _TestCase(
        jwks: '''{"keys":
			[
			  {"kty":"EC",
			   "crv":"P-256",
			   "x":"MKBCTNIcKUSDii11ySs3526iDZ8AiTo7Tu6KPAqv7D4",
			   "y":"4Etl6SRW2YiLUrN5vfvVHuhp7x8PxltmWWlbbM4IFyM",
			   "use":"enc",
			   "kid":"1"},
	 
			  {"kty":"RSA",
			   "n": "0vx7agoebGcQSuuPiLJXZptN9nndrQmbXEps2aiAFbWhM78LhWx4cbbfAAtVT86zwu1RK7aPFFxuhDR1L6tSoc_BJECPebWKRXjBZCiFV4n3oknjhMstn64tZ_2W-5JsGY4Hc5n9yBXArwl93lqt7_RN5w6Cf0h4QyQ5v-65YGjQR0_FDW2QvzqY368QQMicAtaSqzs8KJZgnYb9c7d0zgdAZHzu6qMQvRL5hajrn1n91CbOpbISD08qNLyrdkt-bFTWhAI4vMQFh6WeZu0fM4lFd2NcRwr3XPksINHaQ-G_xBniIqbw0Ls1jF44-csFCur-kEgU8awapJzKnqDKgw",
			   "e":"AQAB",
			   "alg":"RS256",
			   "kid":"2011-04-29"}
			]
		  }''',
        keySet: JsonWebKeySet([
          JsonWebKey(
            keyType: KeyType.EllipticCurve,
            ellipticCurve: EllipticCurve.P256,
            x: base64UrlUintDecode(
                'MKBCTNIcKUSDii11ySs3526iDZ8AiTo7Tu6KPAqv7D4'),
            y: base64UrlUintDecode(
                '4Etl6SRW2YiLUrN5vfvVHuhp7x8PxltmWWlbbM4IFyM'),
            publicKeyUse: PublicKeyUse.encryption,
            keyId: '1',
          ),
          JsonWebKey(
            keyType: KeyType.RSA,
            n: base64UrlUintDecode(
                '0vx7agoebGcQSuuPiLJXZptN9nndrQmbXEps2aiAFbWhM78LhWx4cbbfAAtVT86zwu1RK7aPFFxuhDR1L6tSoc_BJECPebWKRXjBZCiFV4n3oknjhMstn64tZ_2W-5JsGY4Hc5n9yBXArwl93lqt7_RN5w6Cf0h4QyQ5v-65YGjQR0_FDW2QvzqY368QQMicAtaSqzs8KJZgnYb9c7d0zgdAZHzu6qMQvRL5hajrn1n91CbOpbISD08qNLyrdkt-bFTWhAI4vMQFh6WeZu0fM4lFd2NcRwr3XPksINHaQ-G_xBniIqbw0Ls1jF44-csFCur-kEgU8awapJzKnqDKgw'),
            e: BigInt.from(65537),
            algorithm: Algorithm.RSASHA256,
            keyId: '2011-04-29',
          ),
        ]),
      )
    ];

    for (var i = 0; i < tests.length; i++) {
      test('$i', () {
        final keySet = JsonWebKeySet.fromJson(jsonDecode(tests[i].jwks));
        expect(keySet, tests[i].keySet);
      });
    }
  });
}
