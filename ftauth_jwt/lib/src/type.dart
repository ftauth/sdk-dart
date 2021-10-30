enum TokenType {
  jwt,
  access,
  dpop,
}

extension TokenTypeX on TokenType {
  String get code {
    switch (this) {
      case TokenType.jwt:
        return 'JWT';
      case TokenType.access:
        return 'at+jwt';
      case TokenType.dpop:
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
