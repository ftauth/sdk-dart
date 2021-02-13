import 'package:crypto/crypto.dart';
import 'package:ftauth/src/crypto/hmac.dart';
import 'package:ftauth/src/crypto/rsa.dart';
import 'package:ftauth/src/jwt/alg.dart';
import 'package:ftauth/src/jwt/crypto.dart';
import 'package:ftauth/src/jwt/key.dart';

extension JWKCryptoKey on JsonWebKey {
  Verifier get verifier {
    switch (algorithm) {
      case Algorithm.HMACSHA256:
        return HmacKey(sha256, k!);
      case Algorithm.HMACSHA384:
        return HmacKey(sha384, k!);
      case Algorithm.HMACSHA512:
        return HmacKey(sha512, k!);
      case Algorithm.PSSSHA256:
      case Algorithm.PSSSHA384:
      case Algorithm.PSSSHA512:
        return RsaPublicKey.fromJwk(this);
      case Algorithm.ECDSASHA256:
        // TODO: Handle this case.
        break;
      case Algorithm.ECDSASHA384:
        // TODO: Handle this case.
        break;
      case Algorithm.ECDSASHA512:
        // TODO: Handle this case.
        break;
      default:
        break;
    }
    throw UnsupportedError('Algorithm not supported: $algorithm');
  }

  Signer get signer {
    switch (algorithm) {
      case Algorithm.HMACSHA256:
        return HmacKey(sha256, k!);
      case Algorithm.HMACSHA384:
        return HmacKey(sha384, k!);
      case Algorithm.HMACSHA512:
        return HmacKey(sha512, k!);
      case Algorithm.PSSSHA256:
      case Algorithm.PSSSHA384:
      case Algorithm.PSSSHA512:
        return RsaPrivateKey.fromJwk(this);
      case Algorithm.ECDSASHA256:
        // TODO: Handle this case.
        break;
      case Algorithm.ECDSASHA384:
        // TODO: Handle this case.
        break;
      case Algorithm.ECDSASHA512:
        // TODO: Handle this case.
        break;
      default:
        break;
    }
    throw UnsupportedError('Algorithm not supported: $algorithm');
  }
}
