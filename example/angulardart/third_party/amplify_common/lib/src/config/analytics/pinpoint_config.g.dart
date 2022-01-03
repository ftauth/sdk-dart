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

part of 'pinpoint_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PinpointPluginConfig _$PinpointPluginConfigFromJson(
        Map<String, Object?> json) =>
    PinpointPluginConfig(
      pinpointAnalytics: PinpointAnalytics.fromJson(
          json['pinpointAnalytics'] as Map<String, Object?>),
      pinpointTargeting: PinpointTargeting.fromJson(
          json['pinpointTargeting'] as Map<String, Object?>),
    );

Map<String, Object?> _$PinpointPluginConfigToJson(
        PinpointPluginConfig instance) =>
    <String, Object?>{
      'pinpointAnalytics': instance.pinpointAnalytics.toJson(),
      'pinpointTargeting': instance.pinpointTargeting.toJson(),
    };

PinpointAnalytics _$PinpointAnalyticsFromJson(Map<String, Object?> json) =>
    PinpointAnalytics(
      appId: json['appId'] as String,
      region: json['region'] as String,
    );

Map<String, Object?> _$PinpointAnalyticsToJson(PinpointAnalytics instance) =>
    <String, Object?>{
      'appId': instance.appId,
      'region': instance.region,
    };

PinpointTargeting _$PinpointTargetingFromJson(Map<String, Object?> json) =>
    PinpointTargeting(
      region: json['region'] as String,
    );

Map<String, Object?> _$PinpointTargetingToJson(PinpointTargeting instance) =>
    <String, Object?>{
      'region': instance.region,
    };
