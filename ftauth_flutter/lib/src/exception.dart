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

abstract class PlatformExceptionCodes {
  static const auth = 'AUTH';
  static const authCancelled = 'AUTH_CANCELLED';
  static const authUnknown = 'AUTH_UNKNOWN';
  static const invalidArguments = 'INVALID_ARGUMENTS';
  static const couldNotLaunchWebview = 'WEBVIEW';
  static const keyNotFound = 'KEY_NOT_FOUND';
  static const keystoreAccess = 'KEYSTORE_ACCESS';
  static const keystoreUnknown = 'KEYSTORE_UNKNOWN';
  static const unknown = 'UNKNOWN';
  static const unsupportedPlatform = 'UNSUPPORTED_PLATFORM';
  static const couldNotInitialize = 'INITIALIZATION_ERROR';
}
