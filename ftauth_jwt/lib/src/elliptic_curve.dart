enum EllipticCurve { p256, p384, p521 }

extension EllipticCurveX on EllipticCurve {
  String get code {
    switch (this) {
      case EllipticCurve.p256:
        return 'P-256';
      case EllipticCurve.p384:
        return 'P-384';
      case EllipticCurve.p521:
        return 'P-521';
    }
  }

  static String? toJson(EllipticCurve? crv) => crv?.code;

  static EllipticCurve? fromJson(String? json) {
    if (json == null) return null;
    return EllipticCurve.values.firstWhere((element) => element.code == json);
  }
}
