enum Algorithm {
  HMACSHA256,
  HMACSHA384,
  HMACSHA512,
  RSASHA256,
  RSASHA384,
  RSASHA512,
  ECDSASHA256,
  ECDSASHA384,
  ECDSASHA512,
  PSSSHA256,
  PSSSHA384,
  PSSSHA512,
  None,
}

extension AlgorithmX on Algorithm {
  String get code {
    switch (this) {
      case Algorithm.HMACSHA256:
        return 'HS256';
      case Algorithm.HMACSHA384:
        return 'HS384';
      case Algorithm.HMACSHA512:
        return 'HS512';
      case Algorithm.RSASHA256:
        return 'RS256';
      case Algorithm.RSASHA384:
        return 'RS384';
      case Algorithm.RSASHA512:
        return 'RS512';
      case Algorithm.ECDSASHA256:
        return 'ES256';
      case Algorithm.ECDSASHA384:
        return 'ES384';
      case Algorithm.ECDSASHA512:
        return 'ES512';
      case Algorithm.PSSSHA256:
        return 'PS256';
      case Algorithm.PSSSHA384:
        return 'PS384';
      case Algorithm.PSSSHA512:
        return 'PS512';
      case Algorithm.None:
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

  bool get isValid {
    switch (this) {
      case Algorithm.HMACSHA256:
      case Algorithm.HMACSHA384:
      case Algorithm.HMACSHA512:
      case Algorithm.ECDSASHA256:
      case Algorithm.ECDSASHA384:
      case Algorithm.ECDSASHA512:
      case Algorithm.RSASHA256:
      case Algorithm.RSASHA384:
      case Algorithm.RSASHA512:
        return true;
      case Algorithm.PSSSHA256:
      case Algorithm.PSSSHA384:
      case Algorithm.PSSSHA512:
      case Algorithm.None:
        return false;
    }
  }
}
