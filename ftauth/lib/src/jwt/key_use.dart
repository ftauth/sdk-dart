enum PublicKeyUse {
  signature,
  encryption,
}

extension PublicKeyUseX on PublicKeyUse {
  String get code {
    switch (this) {
      case PublicKeyUse.signature:
        return 'sig';
      case PublicKeyUse.encryption:
        return 'enc';
    }
  }

  static String? toJson(PublicKeyUse? use) {
    return use?.code;
  }

  static PublicKeyUse? fromJson(String? use) {
    if (use == null) return null;
    return PublicKeyUse.values.firstWhere((element) => element.code == use);
  }
}
