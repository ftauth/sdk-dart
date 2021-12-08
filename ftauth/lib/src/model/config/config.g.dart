// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Config _$ConfigFromJson(Map<String, dynamic> json) => Config(
      provider: $enumDecodeNullable(_$ProviderEnumMap, json['provider']) ??
          Provider.generic,
      gatewayUrl: json['gateway_url'] as String,
      clientId: json['client_id'] as String,
      clientSecret: json['client_secret'] as String?,
      clientType:
          $enumDecodeNullable(_$ClientTypeEnumMap, json['client_type']) ??
              ClientType.public,
      scopes: (json['scopes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      redirectUri: json['redirect_uri'] as String,
      grantTypes: (json['grant_types'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      accessTokenFormat: $enumDecodeNullable(
              _$TokenFormatEnumMap, json['access_token_format']) ??
          TokenFormat.jwt,
      refreshTokenFormat: $enumDecodeNullable(
              _$TokenFormatEnumMap, json['refresh_token_format']) ??
          TokenFormat.custom,
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

const _$ProviderEnumMap = {
  Provider.ftauth: 'ftauth',
  Provider.generic: 'generic',
};

const _$ClientTypeEnumMap = {
  ClientType.public: 'public',
  ClientType.confidential: 'confidential',
};

const _$TokenFormatEnumMap = {
  TokenFormat.jwt: 'jwt',
  TokenFormat.custom: 'custom',
};
