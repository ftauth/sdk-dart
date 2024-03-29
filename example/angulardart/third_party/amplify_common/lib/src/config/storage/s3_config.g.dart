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

part of 's3_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

S3PluginConfig _$S3PluginConfigFromJson(Map<String, Object?> json) =>
    S3PluginConfig(
      bucket: json['bucket'] as String,
      region: json['region'] as String,
      defaultAccessLevel: $enumDecodeNullable(
              _$StorageAccessLevelEnumMap, json['defaultAccessLevel']) ??
          StorageAccessLevel.guest,
    );

Map<String, Object?> _$S3PluginConfigToJson(S3PluginConfig instance) =>
    <String, Object?>{
      'bucket': instance.bucket,
      'region': instance.region,
      'defaultAccessLevel':
          _$StorageAccessLevelEnumMap[instance.defaultAccessLevel],
    };

const _$StorageAccessLevelEnumMap = {
  StorageAccessLevel.guest: 'guest',
  StorageAccessLevel.private: 'private',
  StorageAccessLevel.protected: 'protected',
};
