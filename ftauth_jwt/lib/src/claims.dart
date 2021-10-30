import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'type.dart';
import 'key.dart';
import 'prefs.dart';
import 'exception.dart';
import 'util.dart';

part 'claims.g.dart';

const _standardClaims = [
  'iss',
  'sub',
  'aud',
  'exp',
  'nbf',
  'iat',
  'jti',
  'nonce',
  'cnf',
  'scope',
  'htm',
  'htu',
];

const _ftauthClaims = [
  'client_id',
  'userInfo',
];

const _reservedClaims = [
  ..._standardClaims,
  ..._ftauthClaims,
];

@serialize
class JsonWebClaims {
  @JsonKey(name: 'iss')
  final String? issuer;

  @JsonKey(name: 'sub')
  final String? subject;

  @JsonKey(name: 'aud')
  final String? audience;

  @JsonKey(name: 'exp', fromJson: decodeDateTime, toJson: encodeDateTime)
  final DateTime? expiration;

  @JsonKey(name: 'nbf', fromJson: decodeDateTime, toJson: encodeDateTime)
  final DateTime? notBefore;

  @JsonKey(name: 'iat', fromJson: decodeDateTime, toJson: encodeDateTime)
  final DateTime? issuedAt;

  @JsonKey(name: 'jti')
  final String? jwtId;

  @JsonKey(name: 'nonce')
  final String? nonce;

  @JsonKey(name: 'cnf')
  final ConfirmationClaim? confirmation;

  @JsonKey(name: 'scope')
  final String? scope;

  @JsonKey(name: 'htm')
  final String? httpMethod;

  @JsonKey(name: 'htu')
  final String? httpUri;

  @JsonKey(ignore: true)
  final Map<String, dynamic> customClaims;

  JsonWebClaims({
    this.issuer,
    this.subject,
    this.audience,
    this.expiration,
    this.notBefore,
    this.issuedAt,
    this.jwtId,
    this.nonce,
    this.confirmation,
    this.scope,
    this.httpMethod,
    this.httpUri,
    Map<String, dynamic>? customClaims,
  }) : customClaims = customClaims ?? {};

  @override
  List<Object?> get props => [
        issuer,
        subject,
        audience,
        expiration,
        notBefore,
        issuedAt,
        jwtId,
        nonce,
        confirmation,
        scope,
        httpMethod,
        httpUri,
        customClaims,
      ];

  Map<String, dynamic>? get ftauthClaims => customClaims['https://ftauth.io'];

  factory JsonWebClaims.fromJson(Map<String, dynamic> json) {
    var instance = _$JsonWebClaimsFromJson(json);
    final customClaims =
        json.keys.where((key) => !_reservedClaims.contains(key));
    instance.customClaims
        .addEntries(customClaims.map((key) => MapEntry(key, json[key])));
    return instance;
  }

  Map<String, dynamic> toJson() {
    final map = _$JsonWebClaimsToJson(this);
    final keys = [...map.keys, ...customClaims.keys]..sort();
    return {
      for (final key in keys) key: map[key] ?? customClaims[key],
    };
  }

  List<int> encode() => utf8.encode(jsonEncode(toJson()));
  String encodeBase64() => base64RawUrl.encode(encode());

  void assertValid(TokenType type) {
    if (type == TokenType.jwt) {
      // TODO: Define general JWT requirements
      return;
    }
    if (issuedAt == null) {
      throw MissingParameterExeception('iat');
    }
    switch (type) {
      case TokenType.jwt:
        break;
      case TokenType.access:
        if (issuer == null) {
          throw MissingParameterExeception('iss');
        }
        if (subject == null) {
          throw MissingParameterExeception('sub');
        }
        if (audience == null) {
          throw MissingParameterExeception('aud');
        }
        if (expiration == null) {
          throw MissingParameterExeception('exp');
        }
        if (scope == null) {
          throw MissingParameterExeception('scope');
        }
        break;
      case TokenType.dpop:
        if (jwtId == null) {
          throw MissingParameterExeception('jti');
        }
        if (httpMethod == null) {
          throw MissingParameterExeception('htm');
        }
        if (httpUri == null) {
          throw MissingParameterExeception('htu');
        }
        break;
    }
  }
}

@serialize
class ConfirmationClaim extends Equatable {
  @JsonKey(name: 'jwk')
  final JsonWebKey? key;

  @JsonKey(name: 'jkt')
  final String? sha256Thumbprint;

  ConfirmationClaim({
    this.key,
    this.sha256Thumbprint,
  }) : assert(key != null || sha256Thumbprint != null);

  @override
  List<Object?> get props => [key, sha256Thumbprint];

  factory ConfirmationClaim.fromJson(Map<String, dynamic> json) =>
      _$ConfirmationClaimFromJson(json);

  Map<String, dynamic> toJson() => _$ConfirmationClaimToJson(this);
}
