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

part of 'pinpoint_targeting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CognitoPinpointTargetingConfig _$CognitoPinpointTargetingConfigFromJson(
        Map<String, Object?> json) =>
    CognitoPinpointTargetingConfig(
      region: json['Region'] as String,
    );

Map<String, Object?> _$CognitoPinpointTargetingConfigToJson(
        CognitoPinpointTargetingConfig instance) =>
    <String, Object?>{
      'Region': instance.region,
    };
