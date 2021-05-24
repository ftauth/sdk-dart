// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Config _$ConfigFromJson(Map<String, dynamic> json) {
  return Config(
    provider: _$enumDecode(_$ProviderEnumMap, json['provider']),
    gatewayUrl: json['gateway_url'] as String,
    clientId: json['client_id'] as String,
    clientSecret: json['client_secret'] as String?,
    clientType: _$enumDecode(_$ClientTypeEnumMap, json['client_type']),
    scopes: (json['scopes'] as List<dynamic>).map((e) => e as String).toList(),
    redirectUri: json['redirect_uri'] as String,
    grantTypes: (json['grant_types'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    accessTokenFormat:
        _$enumDecode(_$TokenFormatEnumMap, json['access_token_type']),
    refreshTokenFormat:
        _$enumDecode(_$TokenFormatEnumMap, json['refresh_token_type']),
    authorizationUri: json['authorization_uri'] == null
        ? null
        : Uri.parse(json['authorization_uri'] as String),
    tokenUri: json['token_uri'] == null
        ? null
        : Uri.parse(json['token_uri'] as String),
    userInfoUri: json['user_info_uri'] == null
        ? null
        : Uri.parse(json['user_info_uri'] as String),
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

const _$ProviderEnumMap = {
  Provider.ftauth: 'ftauth',
  Provider.generic: 'generic',
};

const _$ClientTypeEnumMap = {
  ClientType.public: 'public',
  ClientType.confidential: 'confidential',
};

const _$TokenFormatEnumMap = {
  TokenFormat.JWT: 'JWT',
  TokenFormat.custom: 'custom',
};
