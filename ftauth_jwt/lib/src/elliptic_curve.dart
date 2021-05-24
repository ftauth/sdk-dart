enum EllipticCurve { P256, P384, P521 }

extension EllipticCurveX on EllipticCurve {
  String get code {
    switch (this) {
      case EllipticCurve.P256:
        return 'P-256';
      case EllipticCurve.P384:
        return 'P-384';
      case EllipticCurve.P521:
        return 'P-521';
    }
  }

  static String? toJson(EllipticCurve? crv) => crv?.code;

  static EllipticCurve? fromJson(String? json) {
    if (json == null) return null;
    return EllipticCurve.values.firstWhere((element) => element.code == json);
  }
}
