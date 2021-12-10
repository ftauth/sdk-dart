import 'package:amplify_common/amplify_common.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'amazon_location_services_config.g.dart';

@internal
class AmazonLocationServicesPluginConfigFactory
    extends AmplifyPluginConfigFactory {
  const AmazonLocationServicesPluginConfigFactory();

  @override
  AmplifyPluginConfig build(Map<String, Object?> json) {
    return AmazonLocationServicesPluginConfig.fromJson(json);
  }

  @override
  String get name => AmazonLocationServicesPluginConfig.pluginKey;
}

@amplifySerializable
class AmazonLocationServicesPluginConfig
    with AWSEquatable<AmazonLocationServicesPluginConfig>, AWSSerializable
    implements AmplifyPluginConfig {
  const AmazonLocationServicesPluginConfig({
    this.region,
    this.maps,
  });

  factory AmazonLocationServicesPluginConfig.fromJson(
          Map<String, Object?> json) =>
      _$AmazonLocationServicesPluginConfigFromJson(json);

  static const pluginKey = 'amazon_location_services';

  final String? region;
  final AmazonLocationServicesMaps? maps;

  @override
  String get name => pluginKey;

  @override
  List<Object?> get props => [];

  @override
  Map<String, Object?> toJson() =>
      _$AmazonLocationServicesPluginConfigToJson(this);
}

@amplifySerializable
class AmazonLocationServicesMaps
    with AWSEquatable<AmazonLocationServicesMaps>, AWSSerializable {
  const AmazonLocationServicesMaps({
    required this.items,
    required this.$default,
  });

  @override
  List<Object?> get props => [items, $default];

  final Map<String, AmazonLocationServicesMap> items;

  @JsonKey(name: 'default')
  final String $default;

  AmazonLocationServicesMap get defaultMap => items[$default]!;

  factory AmazonLocationServicesMaps.fromJson(Map<String, Object?> json) =>
      _$AmazonLocationServicesMapsFromJson(json);

  @override
  Map<String, Object?> toJson() => _$AmazonLocationServicesMapsToJson(this);
}

@amplifySerializable
class AmazonLocationServicesMap
    with AWSEquatable<AmazonLocationServicesMap>, AWSSerializable {
  const AmazonLocationServicesMap({
    required this.style,
  });

  factory AmazonLocationServicesMap.fromJson(Map<String, Object?> json) =>
      _$AmazonLocationServicesMapFromJson(json);

  final String style;

  @override
  List<Object?> get props => [style];

  @override
  Map<String, Object?> toJson() => _$AmazonLocationServicesMapToJson(this);
}
