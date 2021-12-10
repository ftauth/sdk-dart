// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeoConfig _$GeoConfigFromJson(Map<String, dynamic> json) => GeoConfig(
      plugins: AmplifyPluginRegistry.pluginConfigsFromJson(json['plugins']),
    );

Map<String, dynamic> _$GeoConfigToJson(GeoConfig instance) => <String, dynamic>{
      'plugins': instance.plugins.map((k, e) => MapEntry(k, e.toJson())),
    };
