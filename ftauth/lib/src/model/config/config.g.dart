// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Config _$ConfigFromJson(Map<String, dynamic> json) {
  return Config(
    gatewayUrl: json['gateway_url'] as String,
    clientId: json['client_id'] as String,
    clientSecret: json['client_secret'] as String?,
    clientType: _$enumDecode(_$ClientTypeEnumMap, json['client_type']),
    scopes: (json['scopes'] as List<dynamic>).map((e) => e as String).toList(),
    redirectUri: json['redirect_uri'] as String,
    grantTypes: (json['grant_types'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
  );
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

const _$ClientTypeEnumMap = {
  ClientType.public: 'public',
  ClientType.confidential: 'confidential',
};
