import 'package:equatable/equatable.dart';
import 'package:ftauth_jwt/ftauth_jwt.dart' hide TokenType;

import 'token_type.dart';

class Token extends Equatable {
  final String raw;
  final DateTime? _expiry;
  final TokenFormat type;

  /// The parsed JWT.
  late final JsonWebToken? jwt;

  Token(
    this.raw, {
    this.type = TokenFormat.custom,
    DateTime? expiry,
  }) : _expiry = expiry {
    if (type == TokenFormat.JWT) {
      jwt = JsonWebToken.parse(raw);
    } else {
      jwt = null;
    }
  }

  @override
  List<Object?> get props => [
        raw,
        _expiry,
        type,
      ];

  /// When the token expires.
  DateTime? get expiry {
    switch (type) {
      case TokenFormat.JWT:
        return jwt!.claims.expiration;
      case TokenFormat.custom:
        return _expiry;
    }
  }

  /// Whether or not the token is expired.
  bool get isExpired {
    final expiry = this.expiry;
    if (expiry == null) {
      // We must assume the token is not expired if we don't have an expiration.
      return false;
    }
    return expiry.isBefore(DateTime.now());
  }
}
