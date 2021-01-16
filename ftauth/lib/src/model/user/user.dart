import 'package:ftauth/src/jwt/claims.dart';
import 'package:ftauth/src/jwt/token.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake,
  includeIfNull: false,
)
class User {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? provider;

  User({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.provider,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

/// Helper for retrieving a [User] object from a JSON Web Token without
/// polluting the jwt pacakage.
extension UserInfoClaims on JsonWebClaims {
  User? get user {
    if (userInfo != null) {
      return User.fromJson(userInfo!);
    }
    return null;
  }
}

/// Helper for retrieving a [User] object from a JSON Web Token without
/// polluting the jwt pacakage.
extension UserInfoToken on JsonWebToken {
  User? get user => claims.user;
}
