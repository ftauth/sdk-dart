import 'dart:convert';

import 'package:ftauth/src/crypto/crypto_repo.dart';
import 'package:jose/jose.dart';
import 'package:uuid/uuid.dart';

import 'dpop_repo.dart';

class DPoPRepoImpl extends DPoPRepo {
  final CryptoRepo cryptoRepo;

  DPoPRepoImpl(this.cryptoRepo);

  @override
  Future<String> createProof(String httpMethod, Uri httpUri) async {
    final jwk = await cryptoRepo.loadSigningKey();
    final signingKey = JsonWebKey.fromJson(jwk);
    final header = JoseHeader.fromJson({
      'typ': 'dpop+jwt',
      'alg': '',
      'jwk': jwk,
    });
    final htu = Uri(
      scheme: httpUri.scheme,
      host: httpUri.host,
      path: httpUri.path,
    ).toString();
    final claims = JsonWebTokenClaims.fromJson({
      'jti': Uuid().v4(),
      'htm': httpMethod,
      'htu': htu,
      'iat': DateTime.now().millisecondsSinceEpoch,
    });

    final headerStr = header.toBase64EncodedString();
    final payload = claims.toBase64EncodedString();

    final body = '$headerStr.$payload';
    final signature = signingKey.sign(utf8.encode(body));
    return '$body.' + base64Url.encode(signature);
  }
}
