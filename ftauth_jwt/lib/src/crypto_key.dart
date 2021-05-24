import 'package:ftauth_jwt/ftauth_jwt.dart';
import 'package:ftauth_jwt/src/ecdsa.dart';

extension JWKCryptoKey on JsonWebKey {
  Verifier get verifier {
    switch (algorithm) {
      case Algorithm.HMACSHA256:
      case Algorithm.HMACSHA384:
      case Algorithm.HMACSHA512:
        return HmacKey.fromJwk(this);
      case Algorithm.RSASHA256:
      case Algorithm.RSASHA384:
      case Algorithm.RSASHA512:
        return RsaPublicKey.fromJwk(this);
      case Algorithm.ECDSASHA256:
      case Algorithm.ECDSASHA384:
      case Algorithm.ECDSASHA512:
        return EcdsaPublicKey.fromJwk(this);
      default:
        break;
    }
    throw UnsupportedError('Algorithm not supported: $algorithm');
  }

  Signer get signer {
    switch (algorithm) {
      case Algorithm.HMACSHA256:
      case Algorithm.HMACSHA384:
      case Algorithm.HMACSHA512:
        return HmacKey.fromJwk(this);
      case Algorithm.RSASHA256:
      case Algorithm.RSASHA384:
      case Algorithm.RSASHA512:
        return RsaPrivateKey.fromJwk(this);
      case Algorithm.ECDSASHA256:
      case Algorithm.ECDSASHA384:
      case Algorithm.ECDSASHA512:
        return EcdsaPrivateKey.fromJwk(this);
      default:
        break;
    }
    throw UnsupportedError('Algorithm not supported: $algorithm');
  }
}
