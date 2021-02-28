import 'package:ftauth/jwt.dart';
import 'package:ftauth/src/crypto/crypto_repo.dart';
import 'package:ftauth/src/jwt/alg.dart';
import 'package:ftauth/src/jwt/claims.dart';
import 'package:ftauth/src/jwt/header.dart';
import 'package:ftauth/src/jwt/token.dart';
import 'package:ftauth/src/jwt/type.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

import 'dpop_repo.dart';

class DPoPRepoImpl extends DPoPRepo {
  final CryptoRepo cryptoRepo;

  DPoPRepoImpl(this.cryptoRepo);

  // @visibleForTesting
  Future<JsonWebToken> createToken(
    String httpMethod,
    Uri httpUri,
  ) async {
    final publicKey = await cryptoRepo.publicKey;

    final header = JsonWebHeader(
      type: TokenType.DPoP,
      algorithm: Algorithm.RSASHA256,
      jwk: publicKey,
    );

    bool includePort;
    if (httpUri.scheme == 'https') {
      includePort = httpUri.port != 443;
    } else if (httpUri.scheme == 'http') {
      includePort = httpUri.port != 80;
    } else {
      includePort = true;
    }

    // Strip query parameters & fragments and include port, if needed
    final htu = Uri(
      scheme: httpUri.scheme,
      host: httpUri.host,
      path: httpUri.path,
      port: includePort ? httpUri.port : null,
    ).toString();

    final claims = JsonWebClaims(
      jwtId: Uuid().v4(),
      httpMethod: httpMethod,
      httpUri: htu,
      issuedAt: DateTime.now(),
    );

    return JsonWebToken(header: header, claims: claims);
  }

  @override
  Future<String> createProof(String httpMethod, Uri httpUri) async {
    final dpopToken = await createToken(httpMethod, httpUri);
    return dpopToken.encodeBase64(cryptoRepo);
  }
}
