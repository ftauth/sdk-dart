// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'key.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JsonWebKey _$JsonWebKeyFromJson(Map<String, dynamic> json) {
  return JsonWebKey(
    keyType: KeyTypeX.fromJson(json['kty'] as String),
    publicKeyUse: PublicKeyUseX.fromJson(json['use'] as String?),
    keyOperations: (json['key_ops'] as List<dynamic>?)
        ?.map((e) => _$enumDecode(_$KeyOperationEnumMap, e))
        .toList(),
    algorithm: AlgorithmX.tryFromJson(json['alg'] as String?),
    keyId: json['kid'] as String?,
    x509Url: json['x5u'] as String?,
    x509CertChain:
        (json['x5c'] as List<dynamic>?)?.map((e) => e as String).toList(),
    x509Sha1Thumbprint: json['x5t'] as String?,
    x509Sha256Thumbprint: json['x5t#S256'] as String?,
    ellipticCurve: EllipticCurveX.fromJson(json['crv'] as String?),
    x: base64UrlUintTryDecode(json['x'] as String?),
    y: base64UrlUintTryDecode(json['y'] as String?),
    n: base64UrlUintTryDecode(json['n'] as String?),
    e: base64UrlUintTryDecode(json['e'] as String?),
    k: symmetricKeyFromJson(json['k'] as String?),
    d: base64UrlUintTryDecode(json['d'] as String?),
    p: base64UrlUintTryDecode(json['p'] as String?),
    q: base64UrlUintTryDecode(json['q'] as String?),
    dp: base64UrlUintTryDecode(json['dp'] as String?),
    dq: base64UrlUintTryDecode(json['dq'] as String?),
    qi: base64UrlUintTryDecode(json['qi'] as String?),
    otherPrimes: (json['oth'] as List<dynamic>?)
        ?.map((e) => OtherPrime.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$JsonWebKeyToJson(JsonWebKey instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('kty', KeyTypeX.toJson(instance.keyType));
  writeNotNull('use', PublicKeyUseX.toJson(instance.publicKeyUse));
  writeNotNull('key_ops',
      instance.keyOperations?.map((e) => _$KeyOperationEnumMap[e]).toList());
  writeNotNull('alg', AlgorithmX.toJson(instance.algorithm));
  writeNotNull('kid', instance.keyId);
  writeNotNull('x5u', instance.x509Url);
  writeNotNull('x5c', instance.x509CertChain);
  writeNotNull('x5t', instance.x509Sha1Thumbprint);
  writeNotNull('x5t#S256', instance.x509Sha256Thumbprint);
  writeNotNull('crv', EllipticCurveX.toJson(instance.ellipticCurve));
  writeNotNull('x', base64UrlUintEncode(instance.x));
  writeNotNull('y', base64UrlUintEncode(instance.y));
  writeNotNull('n', base64UrlUintEncode(instance.n));
  writeNotNull('e', base64UrlUintEncode(instance.e));
  writeNotNull('k', symmetricKeyToJson(instance.k));
  writeNotNull('d', base64UrlUintEncode(instance.d));
  writeNotNull('p', base64UrlUintEncode(instance.p));
  writeNotNull('q', base64UrlUintEncode(instance.q));
  writeNotNull('dp', base64UrlUintEncode(instance.dp));
  writeNotNull('dq', base64UrlUintEncode(instance.dq));
  writeNotNull('qi', base64UrlUintEncode(instance.qi));
  writeNotNull('oth', instance.otherPrimes);
  return val;
}

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$KeyOperationEnumMap = {
  KeyOperation.sign: 'sign',
  KeyOperation.verify: 'verify',
  KeyOperation.encrypt: 'encrypt',
  KeyOperation.decrypt: 'decrypt',
  KeyOperation.wrapKey: 'wrapKey',
  KeyOperation.unwrapKey: 'unwrapKey',
  KeyOperation.deriveKey: 'deriveKey',
  KeyOperation.deriveBytes: 'deriveBytes',
};
