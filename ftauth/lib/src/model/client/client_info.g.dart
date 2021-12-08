// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClientInfo _$ClientInfoFromJson(Map<String, dynamic> json) => ClientInfo(
      id: json['id'] as String,
      name: json['name'] as String?,
      type: $enumDecode(_$ClientTypeEnumMap, json['type']),
      secret: json['secret'] as String?,
      secretExpiresAt: json['secret_expires_at'] == null
          ? null
          : DateTime.parse(json['secret_expires_at'] as String),
      redirectUris: (json['redirect_uris'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      scopes: ClientInfo._scopesFromJson(json['scopes']),
      jwksUri: json['jwks_uri'] as String?,
      logoUri: json['logo_uri'] as String?,
      grantTypes: (json['grant_types'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      accessTokenLife: json['access_token_life'] as int,
      refreshTokenLife: json['refresh_token_life'] as int,
      providers: (json['providers'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$ProviderEnumMap, e))
              .toList() ??
          const [Provider.ftauth],
    );

Map<String, dynamic> _$ClientInfoToJson(ClientInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$ClientTypeEnumMap[instance.type],
      'secret': instance.secret,
      'secret_expires_at': instance.secretExpiresAt?.toIso8601String(),
      'redirect_uris': instance.redirectUris,
      'scopes': instance.scopes,
      'jwks_uri': instance.jwksUri,
      'logo_uri': instance.logoUri,
      'grant_types': instance.grantTypes,
      'access_token_life': instance.accessTokenLife,
      'refresh_token_life': instance.refreshTokenLife,
      'providers': instance.providers.map((e) => _$ProviderEnumMap[e]).toList(),
    };

const _$ClientTypeEnumMap = {
  ClientType.public: 'public',
  ClientType.confidential: 'confidential',
};

const _$ProviderEnumMap = {
  Provider.ftauth: 'ftauth',
  Provider.generic: 'generic',
};
