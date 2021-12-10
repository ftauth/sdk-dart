/// Common support modules for Amplify Dart and Flutter libraries.
library amplify_common;

export 'package:aws_common/aws_common.dart';

// API
export 'src/api/api_authorization.dart';
export 'src/api/authorization_type.dart';

// Auth
export 'src/auth/cognito/user_attribute_key.dart';
export 'src/auth/user_attribute_key.dart';

// Config
export 'src/config/amplify_config.dart';
export 'src/config/amplify_plugin_config.dart' hide UnknownPluginConfigFactory;
export 'src/config/amplify_plugin_registry.dart';
export 'src/config/analytics/analytics_config.dart';
export 'src/config/api/api_config.dart';
export 'src/config/auth/auth_config.dart';
export 'src/config/geo/geo_config.dart' show GeoConfig;
export 'src/config/storage/storage_config.dart';

// Utilities
export 'src/util/serializable.dart';
