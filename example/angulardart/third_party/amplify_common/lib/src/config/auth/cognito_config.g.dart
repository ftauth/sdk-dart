//
// Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.
// A copy of the License is located at
//
//  http://aws.amazon.com/apache2.0
//
// or in the "license" file accompanying this file. This file is distributed
// on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied. See the License for the specific language governing
// permissions and limitations under the License.
//

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cognito_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CognitoPluginConfig _$CognitoPluginConfigFromJson(Map<String, Object?> json) =>
    CognitoPluginConfig(
      userAgent: json['UserAgent'] as String? ?? 'aws-amplify-cli/0.1.0',
      version: json['Version'] as String? ?? '0.1.0',
      identityManager: json['IdentityManager'] == null
          ? null
          : AWSConfigMap<CognitoIdentityManager>.fromJson(
              json['IdentityManager'] as Map<String, Object?>,
              (value) => CognitoIdentityManager.fromJson(
                  value as Map<String, Object?>)),
      credentialsProvider: json['CredentialsProvider'] == null
          ? null
          : CredentialsProviders.fromJson(
              json['CredentialsProvider'] as Map<String, Object?>),
      cognitoUserPool: json['CognitoUserPool'] == null
          ? null
          : AWSConfigMap<CognitoUserPoolConfig>.fromJson(
              json['CognitoUserPool'] as Map<String, Object?>,
              (value) => CognitoUserPoolConfig.fromJson(
                  value as Map<String, Object?>)),
      auth: json['Auth'] == null
          ? null
          : AWSConfigMap<CognitoAuthConfig>.fromJson(
              json['Auth'] as Map<String, Object?>,
              (value) =>
                  CognitoAuthConfig.fromJson(value as Map<String, Object?>)),
      appSync: json['AppSync'] == null
          ? null
          : AWSConfigMap<CognitoAppSyncConfig>.fromJson(
              json['AppSync'] as Map<String, Object?>,
              (value) =>
                  CognitoAppSyncConfig.fromJson(value as Map<String, Object?>)),
      pinpointAnalytics: json['PinpointAnalytics'] == null
          ? null
          : AWSConfigMap<CognitoPinpointAnalyticsConfig>.fromJson(
              json['PinpointAnalytics'] as Map<String, Object?>,
              (value) => CognitoPinpointAnalyticsConfig.fromJson(
                  value as Map<String, Object?>)),
      pinpointTargeting: json['PinpointTargeting'] == null
          ? null
          : AWSConfigMap<CognitoPinpointTargetingConfig>.fromJson(
              json['PinpointTargeting'] as Map<String, Object?>,
              (value) => CognitoPinpointTargetingConfig.fromJson(
                  value as Map<String, Object?>)),
      s3TransferUtility: json['S3TransferUtility'] == null
          ? null
          : AWSConfigMap<S3TransferUtility>.fromJson(
              json['S3TransferUtility'] as Map<String, Object?>,
              (value) =>
                  S3TransferUtility.fromJson(value as Map<String, Object?>)),
    );

Map<String, Object?> _$CognitoPluginConfigToJson(CognitoPluginConfig instance) {
  final val = <String, Object?>{
    'UserAgent': instance.userAgent,
    'Version': instance.version,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('IdentityManager', instance.identityManager?.toJson());
  writeNotNull('CredentialsProvider', instance.credentialsProvider?.toJson());
  writeNotNull('CognitoUserPool', instance.cognitoUserPool?.toJson());
  writeNotNull('Auth', instance.auth?.toJson());
  writeNotNull('AppSync', instance.appSync?.toJson());
  writeNotNull('PinpointAnalytics', instance.pinpointAnalytics?.toJson());
  writeNotNull('PinpointTargeting', instance.pinpointTargeting?.toJson());
  writeNotNull('S3TransferUtility', instance.s3TransferUtility?.toJson());
  return val;
}
