// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openid_connect_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenIDConnectConfig _$OpenIDConnectConfigFromJson(Map<String, dynamic> json) =>
    OpenIDConnectConfig(
      authTTL: json['authTTL'] as int?,
      clientId: json['clientId'] as String?,
      iatTTL: json['iatTTL'] as int?,
      issuer: json['issuer'] as String,
    );

Map<String, dynamic> _$OpenIDConnectConfigToJson(OpenIDConnectConfig instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('authTTL', instance.authTTL);
  writeNotNull('clientId', instance.clientId);
  writeNotNull('iatTTL', instance.iatTTL);
  val['issuer'] = instance.issuer;
  return val;
}
