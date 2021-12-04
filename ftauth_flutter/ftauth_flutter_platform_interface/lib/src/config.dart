/// The default configuration path.
const kConfigPath = 'assets/ftauth_config.json';

/// A valid FTAuth configuration could not be located at the path specified.
/// If no configuration path was provided, FTAuth defaults to looking in
/// [kConfigPath].
class ConfigNotFoundException implements Exception {
  final String configPath;

  const ConfigNotFoundException(this.configPath);

  @override
  String toString() {
    return 'Configuration file not found at specified path: $configPath';
  }
}
