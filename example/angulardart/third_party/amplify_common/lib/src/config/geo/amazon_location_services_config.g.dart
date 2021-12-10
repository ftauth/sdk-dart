// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'amazon_location_services_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AmazonLocationServicesPluginConfig _$AmazonLocationServicesPluginConfigFromJson(
        Map<String, dynamic> json) =>
    AmazonLocationServicesPluginConfig(
      region: json['region'] as String?,
      maps: json['maps'] == null
          ? null
          : AmazonLocationServicesMaps.fromJson(
              json['maps'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AmazonLocationServicesPluginConfigToJson(
    AmazonLocationServicesPluginConfig instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('region', instance.region);
  writeNotNull('maps', instance.maps?.toJson());
  return val;
}

AmazonLocationServicesMaps _$AmazonLocationServicesMapsFromJson(
        Map<String, dynamic> json) =>
    AmazonLocationServicesMaps(
      items: (json['items'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k, AmazonLocationServicesMap.fromJson(e as Map<String, dynamic>)),
      ),
      $default: json['default'] as String,
    );

Map<String, dynamic> _$AmazonLocationServicesMapsToJson(
        AmazonLocationServicesMaps instance) =>
    <String, dynamic>{
      'items': instance.items.map((k, e) => MapEntry(k, e.toJson())),
      'default': instance.$default,
    };

AmazonLocationServicesMap _$AmazonLocationServicesMapFromJson(
        Map<String, dynamic> json) =>
    AmazonLocationServicesMap(
      style: json['style'] as String,
    );

Map<String, dynamic> _$AmazonLocationServicesMapToJson(
        AmazonLocationServicesMap instance) =>
    <String, dynamic>{
      'style': instance.style,
    };
