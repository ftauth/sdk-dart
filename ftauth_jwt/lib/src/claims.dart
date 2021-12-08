import 'package:canonical_json/canonical_json.dart';
import 'package:collection/collection.dart';
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

@serialize
class JsonWebClaims extends Equatable {
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

  final Map<String, Object?> _customClaims;

  @JsonKey(ignore: true)
  Map<String, Object?> get customClaims => UnmodifiableMapView(_customClaims);

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
    Map<String, Object?>? customClaims,
  }) : _customClaims = customClaims ?? {};

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

  Map<String, Object?> get ftauthClaims {
    final claims =
        customClaims['https://ftauth.io'] as Map<String, Object?>? ?? const {};
    return UnmodifiableMapView(claims);
  }

  factory JsonWebClaims.fromJson(Map<String, Object?> json) {
    var instance = _$JsonWebClaimsFromJson(json);
    final customClaims =
        json.keys.where((key) => !_standardClaims.contains(key));
    instance._customClaims
        .addEntries(customClaims.map((key) => MapEntry(key, json[key])));
    return instance;
  }

  Map<String, Object?> toJson() {
    final map = _$JsonWebClaimsToJson(this);
    final keys = [...map.keys, ...customClaims.keys];
    return {
      for (final key in keys) key: map[key] ?? customClaims[key],
    };
  }

  List<int> encode() => canonicalJson.encode(toJson());
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

  factory ConfirmationClaim.fromJson(Map<String, Object?> json) =>
      _$ConfirmationClaimFromJson(json);

  Map<String, Object?> toJson() => _$ConfirmationClaimToJson(this);
}
