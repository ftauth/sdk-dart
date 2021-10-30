import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:ftauth/ftauth.dart' hide FTAuth;
import 'package:ftauth/ftauth.dart' as ftauth show FTAuth;
import 'package:ftauth_platform_interface/ftauth_platform_interface.dart';
import 'package:ftauth_storage/ftauth_storage.dart';
import 'package:http/http.dart' as http;

/// Wrapper class used for providing a [FTAuthClient] to descendant widgets.
///
/// ```
/// final config = await FlutterConfig.fromAsset();
/// runApp(
///   FTAuth(
///     config,
///     child: MyApp(),
///   ),
/// );
///
/// // Login
/// await FTAuth.of(context).login();
///
/// // Logout
/// await FTAuth.of(context).logout();
///
/// // Fetch Data
/// final ftauthClient = FTAuth.of(context);
/// final userInfo = Uri.parse('https://myapp.com/api/user');
/// final resp = await ftauthClient.get(userInfo);
/// ```
class FTAuth extends InheritedWidget {
  /// Override this value to set the logger for the SSO module.
  static set logger(LoggerInterface newValue) =>
      ftauth.FTAuth.logger = newValue;

  static void debug(String log) => ftauth.FTAuth.debug(log);
  static void info(String log) => ftauth.FTAuth.info(log);
  static void warn(String log) => ftauth.FTAuth.warn(log);
  static void error(String log) => ftauth.FTAuth.error(log);

  final FTAuthClient client;

  FTAuth(
    Config config, {
    Key? key,
    required Widget child,
    http.Client? baseClient,
    Duration? timeout,
    StorageRepo? storageRepo,
    Uint8List? encryptionKey,
    String? appGroup,
    SetupHandler? setup,
    bool? clearOnFreshInstall,
  })  : client = FTAuthClient(
          config,
          baseClient: baseClient,
          timeout: timeout,
          encryptionKey: encryptionKey,
          storageRepo: storageRepo,
          appGroup: appGroup,
          setup: setup,
          clearOnFreshInstall: clearOnFreshInstall,
        ),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant FTAuth oldWidget) => false;

  /// Returns the [FTAuthClient] for [context].
  static FTAuthClient of(BuildContext context, {bool listen = true}) {
    FTAuth? ftauth;
    if (listen) {
      ftauth = context.dependOnInheritedWidgetOfExactType<FTAuth>();
    } else {
      ftauth = context.findAncestorWidgetOfExactType<FTAuth>();
    }
    assert(ftauth != null, 'No FTAuth widget found above this one.');
    return ftauth!.client;
  }
}

class FTAuthClient extends ftauth.FTAuth {
  FTAuthClient(
    Config config, {
    StorageRepo? storageRepo,
    Uint8List? encryptionKey,
    Authorizer? authorizer,
    http.Client? baseClient,
    Duration? timeout,
    String? appGroup,
    SetupHandler? setup,
    bool? clearOnFreshInstall,
  }) : super(
          config,
          authorizer: authorizer,
          baseClient: baseClient,
          timeout: timeout,
          setup: setup,
          encryptionKey: encryptionKey,
          storageRepo: storageRepo ??
              FTAuthSecureStorage(
                appGroup: appGroup,
              ),
          clearOnFreshInstall: clearOnFreshInstall,
        );

  static FTAuthPlatformInterface get _platform =>
      FTAuthPlatformInterface.instance;

  static FTAuthClient of(BuildContext context) {
    final ftauth = context.dependOnInheritedWidgetOfExactType<FTAuth>();
    assert(ftauth != null, 'No FTAuth widget found above this one.');
    return ftauth!.client;
  }

  /// Performs the two-step OAuth process to login the user.
  Future<void> login({
    String? language,
    String? countryCode,
  }) async {
    if (await isLoggedIn) {
      FTAuth.info('User is already logged in.');
      return;
    }

    final url = await authorizer.authorize(
      language: language,
      countryCode: countryCode,
    );

    FTAuth.debug('Launching url: $url');
    try {
      final Map<String, String> parameters = await _platform.login(url);

      await authorizer.exchange(parameters);
    } on Exception catch (e) {
      if (e is PlatformException &&
          e.code == PlatformExceptionCodes.authCancelled) {
        FTAuth.info('Authorization process cancelled.');
      } else {
        FTAuth.error('Error logging in: $e');
      }
      // Cancel the login process
      await authorizer.logout();
      rethrow;
    }
  }
}

class FlutterConfig {
  static Future<Config> fromAsset([String? configPath]) async {
    configPath ??= kConfigPath;
    try {
      return await rootBundle.loadStructuredData(configPath, (value) async {
        final configJson = (json.decode(value) as Map).cast<String, dynamic>();
        return Config.fromJson(configJson);
      });
    } on Exception {
      throw ConfigNotFoundException(configPath);
    }
  }
}
