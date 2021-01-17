import 'package:crypto/crypto.dart';
import 'package:ftauth/src/crypto/hmac.dart';
import 'package:ftauth/src/crypto/rsa.dart';
import 'package:ftauth/src/jwt/alg.dart';
import 'package:ftauth/src/jwt/crypto.dart';
import 'package:ftauth/src/jwt/key.dart';

extension JWKCryptoKey on JsonWebKey {
  CryptoKey get cryptoKey {
    switch (algorithm) {
      case Algorithm.HMACSHA256:
        return HmacKey(sha256, k!);
      case Algorithm.HMACSHA384:
        return HmacKey(sha384, k!);
      case Algorithm.HMACSHA512:
        return HmacKey(sha512, k!);
      case Algorithm.RSASHA256:
      case Algorithm.RSASHA384:
      case Algorithm.RSASHA512:
      case Algorithm.PSSSHA256:
      case Algorithm.PSSSHA384:
      case Algorithm.PSSSHA512:
        if (isPrivate) {
          return RsaPrivateKey.fromJwk(this);
        } else {
          return RsaPublicKey.fromJwk(this);
        }
      case Algorithm.ECDSASHA256:
        // TODO: Handle this case.
        break;
      case Algorithm.ECDSASHA384:
        // TODO: Handle this case.
        break;
      case Algorithm.ECDSASHA512:
        // TODO: Handle this case.
        break;
      case Algorithm.None:
        // TODO: Handle this case.
        break;
    }
    throw UnsupportedError('Algorithm not supported: $algorithm');
  }

  PrivateKey? get privateKey => isPrivate ? cryptoKey as PrivateKey : null;
  PublicKey get publicKey =>
      isPrivate ? (cryptoKey as PrivateKey).publicKey : cryptoKey as PublicKey;
}
