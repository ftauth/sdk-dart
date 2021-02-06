import 'package:ftauth/src/crypto/crypto_repo.dart';
import 'package:ftauth/src/crypto/crypto_key.dart';
import 'package:ftauth/src/jwt/alg.dart';
import 'package:ftauth/src/jwt/claims.dart';
import 'package:ftauth/src/jwt/header.dart';
import 'package:ftauth/src/jwt/key.dart';
import 'package:ftauth/src/jwt/token.dart';
import 'package:ftauth/src/jwt/type.dart';
import 'package:uuid/uuid.dart';

import 'dpop_repo.dart';

class DPoPRepoImpl extends DPoPRepo {
  final CryptoRepo cryptoRepo;

  DPoPRepoImpl(this.cryptoRepo);

  @override
  Future<String> createProof(String httpMethod, Uri httpUri) async {
    final jwk = await cryptoRepo.loadSigningKey();
    final signingKey = JsonWebKey.fromJson(jwk);

    final header = JsonWebHeader(
      type: TokenType.DPoP,
      algorithm: Algorithm.HMACSHA256,
      // jwk: signingKey.publicKey, // TODO: fix, public key should be used here
    );

    // Strip query parameters & fragments
    final htu = Uri(
      scheme: httpUri.scheme,
      host: httpUri.host,
      path: httpUri.path,
    ).toString();

    final claims = JsonWebClaims(
      jwtId: Uuid().v4(),
      httpMethod: httpMethod,
      httpUri: htu,
      issuedAt: DateTime.now(),
    );

    return await JsonWebToken(header: header, claims: claims)
        .encodeBase64(signingKey.privateKey!);
  }
}
