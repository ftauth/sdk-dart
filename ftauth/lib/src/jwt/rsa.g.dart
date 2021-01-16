// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rsa.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtherPrime _$OtherPrimeFromJson(Map<String, dynamic> json) {
  return OtherPrime(
    r: base64UrlUintDecode(json['r'] as String),
    d: base64UrlUintDecode(json['d'] as String),
    t: base64UrlUintDecode(json['t'] as String),
  );
}

Map<String, dynamic> _$OtherPrimeToJson(OtherPrime instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('r', base64UrlUintEncode(instance.r));
  writeNotNull('d', base64UrlUintEncode(instance.d));
  writeNotNull('t', base64UrlUintEncode(instance.t));
  return val;
}
