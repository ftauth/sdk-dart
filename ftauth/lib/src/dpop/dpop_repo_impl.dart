import 'package:ftauth/src/crypto/crypto_repo.dart';
import 'package:ftauth/src/jwt/alg.dart';
import 'package:ftauth/src/jwt/claims.dart';
import 'package:ftauth/src/jwt/header.dart';
import 'package:ftauth/src/jwt/token.dart';
import 'package:ftauth/src/jwt/type.dart';
import 'package:uuid/uuid.dart';

import 'dpop_repo.dart';

class DPoPRepoImpl extends DPoPRepo {
  final CryptoRepo cryptoRepo;

  DPoPRepoImpl(this.cryptoRepo);

  @override
  Future<String> createProof(String httpMethod, Uri httpUri) async {
    final publicKey = await cryptoRepo.publicKey;

    final header = JsonWebHeader(
      type: TokenType.DPoP,
      algorithm: Algorithm.HMACSHA256,
      jwk: publicKey,
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

    final unsigned = JsonWebToken(header: header, claims: claims);
    final signature =
        await cryptoRepo.sign(unsigned.encodeUnsigned().codeUnits);

    return JsonWebToken(header: header, claims: claims, signature: signature)
        .raw;
  }
}
