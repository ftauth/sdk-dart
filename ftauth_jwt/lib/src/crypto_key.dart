import 'package:ftauth_jwt/ftauth_jwt.dart';
import 'package:ftauth_jwt/src/ecdsa.dart';

extension JWKCryptoKey on JsonWebKey {
  Verifier get verifier {
    switch (algorithm) {
      case Algorithm.hmacSha256:
      case Algorithm.hmacSha384:
      case Algorithm.hmacSha512:
        return HmacKey.fromJwk(this);
      case Algorithm.rsaSha256:
      case Algorithm.rsaSha384:
      case Algorithm.rsaSha512:
        return RsaPublicKey.fromJwk(this);
      case Algorithm.ecdsaSha256:
      case Algorithm.ecdsaSha384:
      case Algorithm.ecdsaSha512:
        return EcdsaPublicKey.fromJwk(this);
      default:
        break;
    }
    throw UnsupportedError('Algorithm not supported: $algorithm');
  }

  Signer get signer {
    switch (algorithm) {
      case Algorithm.hmacSha256:
      case Algorithm.hmacSha384:
      case Algorithm.hmacSha512:
        return HmacKey.fromJwk(this);
      case Algorithm.rsaSha256:
      case Algorithm.rsaSha384:
      case Algorithm.rsaSha512:
        return RsaPrivateKey.fromJwk(this);
      case Algorithm.ecdsaSha256:
      case Algorithm.ecdsaSha384:
      case Algorithm.ecdsaSha512:
        return EcdsaPrivateKey.fromJwk(this);
      default:
        break;
    }
    throw UnsupportedError('Algorithm not supported: $algorithm');
  }
}
