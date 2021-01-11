class ConfigNotFoundException implements Exception {
  final String configPath;

  const ConfigNotFoundException(this.configPath);

  @override
  String toString() {
    return 'Configuration file not found at specified path: $configPath';
  }
}
