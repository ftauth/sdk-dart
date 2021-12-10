import 'package:amplify_common/amplify_common.dart';
import 'package:amplify_common/src/config/config_map.dart';

import 'amazon_location_services_config.dart';

export 'amazon_location_services_config.dart'
    hide AmazonLocationServicesPluginConfigFactory;

part 'geo_config.g.dart';

@amplifySerializable
class GeoConfig extends AmplifyPluginConfigMap {
  const GeoConfig({
    required Map<String, AmplifyPluginConfig> plugins,
  }) : super(plugins);

  @override
  AmazonLocationServicesPluginConfig? get awsPlugin =>
      plugins[AmazonLocationServicesPluginConfig.pluginKey]
          as AmazonLocationServicesPluginConfig?;

  factory GeoConfig.fromJson(Map<String, Object?> json) =>
      _$GeoConfigFromJson(json);

  @override
  Map<String, Object?> toJson() => _$GeoConfigToJson(this);
}
