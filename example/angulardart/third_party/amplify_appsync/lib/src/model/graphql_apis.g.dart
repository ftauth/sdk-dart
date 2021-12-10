// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'graphql_apis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GraphqlApi _$GraphqlApiFromJson(Map<String, dynamic> json) => GraphqlApi(
      additionalAuthenticationProviders:
          (json['additionalAuthenticationProviders'] as List<dynamic>?)
              ?.map((e) => AdditionalAuthenticationProvider.fromJson(
                  e as Map<String, dynamic>))
              .toList(),
      apiId: json['apiId'] as String?,
      arn: json['arn'] as String?,
      authenticationType: _$enumDecodeNullable(
          _$AuthenticationTypeEnumMap, json['authenticationType']),
      lambdaAuthorizerConfig: json['lambdaAuthorizerConfig'] == null
          ? null
          : LambdaAuthorizerConfig.fromJson(
              json['lambdaAuthorizerConfig'] as Map<String, dynamic>),
      name: json['name'] as String?,
      openIDConnectConfig: json['openIDConnectConfig'] == null
          ? null
          : OpenIDConnectConfig.fromJson(
              json['openIDConnectConfig'] as Map<String, dynamic>),
      tags: (json['tags'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      uris: (json['uris'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      wafWebAclArn: json['wafWebAclArn'] as String?,
      xrayEnabled: json['xrayEnabled'] as bool?,
    );

Map<String, dynamic> _$GraphqlApiToJson(GraphqlApi instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('additionalAuthenticationProviders',
      instance.additionalAuthenticationProviders);
  writeNotNull('apiId', instance.apiId);
  writeNotNull('arn', instance.arn);
  writeNotNull('authenticationType',
      _$AuthenticationTypeEnumMap[instance.authenticationType]);
  writeNotNull('lambdaAuthorizerConfig', instance.lambdaAuthorizerConfig);
  writeNotNull('name', instance.name);
  writeNotNull('openIDConnectConfig', instance.openIDConnectConfig);
  writeNotNull('tags', instance.tags);
  writeNotNull('uris', instance.uris);
  writeNotNull('wafWebAclArn', instance.wafWebAclArn);
  writeNotNull('xrayEnabled', instance.xrayEnabled);
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

K? _$enumDecodeNullable<K, V>(
  Map<K, V> enumValues,
  dynamic source, {
  K? unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<K, V>(enumValues, source, unknownValue: unknownValue);
}

const _$AuthenticationTypeEnumMap = {
  AuthenticationType.apiKey: 'API_KEY',
  AuthenticationType.awsIam: 'AWS_IAM',
  AuthenticationType.cognitoUserPools: 'AMAZON_COGNITO_USER_POOLS',
  AuthenticationType.openIDConnect: 'OPENID_CONNECT',
  AuthenticationType.awsLambda: 'AWS_LAMBDA',
};

AdditionalAuthenticationProvider _$AdditionalAuthenticationProviderFromJson(
        Map<String, dynamic> json) =>
    AdditionalAuthenticationProvider(
      authenticationType:
          _$enumDecode(_$AuthenticationTypeEnumMap, json['authenticationType']),
      lambdaAuthorizerConfig: json['lambdaAuthorizerConfig'] == null
          ? null
          : LambdaAuthorizerConfig.fromJson(
              json['lambdaAuthorizerConfig'] as Map<String, dynamic>),
      openIDConnectConfig: json['openIDConnectConfig'] == null
          ? null
          : OpenIDConnectConfig.fromJson(
              json['openIDConnectConfig'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AdditionalAuthenticationProviderToJson(
    AdditionalAuthenticationProvider instance) {
  final val = <String, dynamic>{
    'authenticationType':
        _$AuthenticationTypeEnumMap[instance.authenticationType],
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('lambdaAuthorizerConfig', instance.lambdaAuthorizerConfig);
  writeNotNull('openIDConnectConfig', instance.openIDConnectConfig);
  return val;
}

LambdaAuthorizerConfig _$LambdaAuthorizerConfigFromJson(
        Map<String, dynamic> json) =>
    LambdaAuthorizerConfig(
      authorizerResultTtlInSeconds: json['authorizerResultTtlInSeconds'] as int,
      authorizerUri: json['authorizerUri'] as String,
      identityValidationExpression:
          json['identityValidationExpression'] as String?,
    );

Map<String, dynamic> _$LambdaAuthorizerConfigToJson(
    LambdaAuthorizerConfig instance) {
  final val = <String, dynamic>{
    'authorizerResultTtlInSeconds': instance.authorizerResultTtlInSeconds,
    'authorizerUri': instance.authorizerUri,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull(
      'identityValidationExpression', instance.identityValidationExpression);
  return val;
}
