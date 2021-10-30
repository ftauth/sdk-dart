enum KeyType {
  ellipticCurve,
  rsa,
  octet,
}

extension KeyTypeX on KeyType {
  String get code {
    switch (this) {
      case KeyType.ellipticCurve:
        return 'EC';
      case KeyType.rsa:
        return 'RSA';
      case KeyType.octet:
        return 'oct';
    }
  }

  static String? toJson(KeyType? kty) {
    return kty?.code;
  }

  static KeyType fromJson(String kty) {
    return KeyType.values.firstWhere((element) => element.code == kty);
  }

  static KeyType? tryFromJson(String? kty) {
    if (kty == null) return null;
    try {
      return fromJson(kty);
    } on StateError {
      return null;
    }
  }
}
