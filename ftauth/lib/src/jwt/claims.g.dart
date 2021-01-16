// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claims.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JsonWebClaims _$JsonWebClaimsFromJson(Map<String, dynamic> json) {
  return JsonWebClaims(
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
    clientId: json['client_id'] as String?,
    scope: json['scope'] as String?,
    httpMethod: json['htm'] as String?,
    httpUri: json['htu'] as String?,
    userInfo: json['userInfo'] as Map<String, dynamic>?,
  );
}

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
  writeNotNull('cnf', instance.confirmation);
  writeNotNull('client_id', instance.clientId);
  writeNotNull('scope', instance.scope);
  writeNotNull('htm', instance.httpMethod);
  writeNotNull('htu', instance.httpUri);
  writeNotNull('userInfo', instance.userInfo);
  return val;
}

ConfirmationClaim _$ConfirmationClaimFromJson(Map<String, dynamic> json) {
  return ConfirmationClaim(
    key: JsonWebKey.fromJson(json['jwk'] as Map<String, dynamic>),
    sha256Thumbprint: json['jkt'] as String,
  );
}

Map<String, dynamic> _$ConfirmationClaimToJson(ConfirmationClaim instance) =>
    <String, dynamic>{
      'jwk': instance.key,
      'jkt': instance.sha256Thumbprint,
    };
