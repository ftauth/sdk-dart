import 'package:ftauth/ftauth.dart';

/// Strategy to use when FTAuth is configured with a new configuration (a new
/// client ID).
enum ConfigChangeStrategy {
  /// Clears the current keychain information and re-initializes thes SDK with
  /// the new configuration.
  clear,

  /// Ignores the new configuration. Requires calling [FTAuth.logout] with
  /// `deinit` = `true` before a new configuration can be used.
  ignore,
}
