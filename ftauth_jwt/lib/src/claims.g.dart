// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claims.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JsonWebClaims _$JsonWebClaimsFromJson(Map<String, dynamic> json) =>
    JsonWebClaims(
      issuer: json['iss'] as String?,
      subject: json['sub'] as String?,
      audience: json['aud'] as String?,
      expiration: decodeDateTime(json['exp'] as int?),
      notBefore: decodeDateTime(json['nbf'] as int?),
      issuedAt: decodeDateTime(json['iat'] as int?),
      jwtId: json['jti'] as String?,
      nonce: json['nonce'] as String?,
      confirmation: json['cnf'] == null
          ? null
          : ConfirmationClaim.fromJson(json['cnf'] as Map<String, dynamic>),
      scope: json['scope'] as String?,
      httpMethod: json['htm'] as String?,
      httpUri: json['htu'] as String?,
    );

Map<String, dynamic> _$JsonWebClaimsToJson(JsonWebClaims instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('iss', instance.issuer);
  writeNotNull('sub', instance.subject);
  writeNotNull('aud', instance.audience);
  writeNotNull('exp', encodeDateTime(instance.expiration));
  writeNotNull('nbf', encodeDateTime(instance.notBefore));
  writeNotNull('iat', encodeDateTime(instance.issuedAt));
  writeNotNull('jti', instance.jwtId);
  writeNotNull('nonce', instance.nonce);
  writeNotNull('cnf', instance.confirmation?.toJson());
  writeNotNull('scope', instance.scope);
  writeNotNull('htm', instance.httpMethod);
  writeNotNull('htu', instance.httpUri);
  return val;
}

ConfirmationClaim _$ConfirmationClaimFromJson(Map<String, dynamic> json) =>
    ConfirmationClaim(
      key: json['jwk'] == null
          ? null
          : JsonWebKey.fromJson(json['jwk'] as Map<String, dynamic>),
      sha256Thumbprint: json['jkt'] as String?,
    );

Map<String, dynamic> _$ConfirmationClaimToJson(ConfirmationClaim instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('jwk', instance.key?.toJson());
  writeNotNull('jkt', instance.sha256Thumbprint);
  return val;
}
