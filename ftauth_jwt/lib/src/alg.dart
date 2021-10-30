import 'package:ftauth_jwt/src/key_type.dart';

enum Algorithm {
  hmacSha256,
  hmacSha384,
  hmacSha512,
  rsaSha256,
  rsaSha384,
  rsaSha512,
  ecdsaSha256,
  ecdsaSha384,
  ecdsaSha512,
  pssSha256,
  pssSha384,
  pssSha512,
  none,
}

extension AlgorithmX on Algorithm {
  String get code {
    switch (this) {
      case Algorithm.hmacSha256:
        return 'HS256';
      case Algorithm.hmacSha384:
        return 'HS384';
      case Algorithm.hmacSha512:
        return 'HS512';
      case Algorithm.rsaSha256:
        return 'RS256';
      case Algorithm.rsaSha384:
        return 'RS384';
      case Algorithm.rsaSha512:
        return 'RS512';
      case Algorithm.ecdsaSha256:
        return 'ES256';
      case Algorithm.ecdsaSha384:
        return 'ES384';
      case Algorithm.ecdsaSha512:
        return 'ES512';
      case Algorithm.pssSha256:
        return 'PS256';
      case Algorithm.pssSha384:
        return 'PS384';
      case Algorithm.pssSha512:
        return 'PS512';
      case Algorithm.none:
        return 'none';
    }
  }

  static String? toJson(Algorithm? alg) => alg?.code;

  static Algorithm fromJson(String json) {
    return Algorithm.values.firstWhere((element) => element.code == json);
  }

  static Algorithm? tryFromJson(String? json) {
    if (json == null) return null;
    try {
      return fromJson(json);
    } on StateError {
      return null;
    }
  }

  KeyType? get keyType {
    switch (this) {
      case Algorithm.hmacSha256:
      case Algorithm.hmacSha384:
      case Algorithm.hmacSha512:
        return KeyType.octet;
      case Algorithm.ecdsaSha256:
      case Algorithm.ecdsaSha384:
      case Algorithm.ecdsaSha512:
        return KeyType.ellipticCurve;
      case Algorithm.rsaSha256:
      case Algorithm.rsaSha384:
      case Algorithm.rsaSha512:
      case Algorithm.pssSha256:
      case Algorithm.pssSha384:
      case Algorithm.pssSha512:
        return KeyType.rsa;
      case Algorithm.none:
        return null;
    }
  }

  bool get isValid {
    switch (this) {
      case Algorithm.hmacSha256:
      case Algorithm.hmacSha384:
      case Algorithm.hmacSha512:
      case Algorithm.ecdsaSha256:
      case Algorithm.ecdsaSha384:
      case Algorithm.ecdsaSha512:
      case Algorithm.rsaSha256:
      case Algorithm.rsaSha384:
      case Algorithm.rsaSha512:
        return true;
      case Algorithm.pssSha256:
      case Algorithm.pssSha384:
      case Algorithm.pssSha512:
      case Algorithm.none:
        return false;
    }
  }
}
