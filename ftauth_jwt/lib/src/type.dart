enum TokenType {
  JWT,
  Access,
  DPoP,
}

extension TokenTypeX on TokenType {
  String get code {
    switch (this) {
      case TokenType.JWT:
        return 'JWT';
      case TokenType.Access:
        return 'at+jwt';
      case TokenType.DPoP:
        return 'dpop+jwt';
    }
  }

  static TokenType? tryFromJson(String? json) {
    if (json == null) return null;
    try {
      return fromJson(json);
    } on StateError {
      return null;
    }
  }

  static TokenType fromJson(String json) {
    return TokenType.values.firstWhere((element) => element.code == json);
  }

  static String? toJson(TokenType? type) => type?.code;
}
