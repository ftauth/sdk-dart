import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:ftauth/ftauth.dart' as ftauth;
import 'package:ftauth_flutter/src/storage/secure_storage.dart';
import 'package:webcrypto/webcrypto.dart';

import 'crypto_repo.dart';
import 'exception.dart';
import 'flutter_authorizer.dart';

const _configPath = 'assets/ftauth_config.json';

/// A widget meant to wrap a top-level MaterialApp to provide an FTAuth
/// config to all decendant widgets, making login/authorize calls simpler.
///
///
/// ```
/// import 'package:ftauth_flutter/ftauth_flutter.dart';
///
/// Future<void> main() async {
///   final config = FTAuthConfig(
///     gatewayUrl: 'http://localhost:8000',
///   );
///
///   await FTAuth.initFlutter(config: config);
///
///   runApp(
///     FTAuth(
///       config: config,
///       child: MyApp(),
///     ),
///   );
/// }
/// ```
class FTAuth extends InheritedWidget {
  final ftauth.FTAuthConfig config;

  FTAuth({
    required this.config,
    required Widget child,
  }) : super(child: child);

  /// Returns the FTAuth config provided to the Auth widget on creation.
  ///
  /// Make sure to wrap your top-level [MaterialApp] in an [FTAuth] widget to have
  /// access to it later.
  static ftauth.FTAuthConfig of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FTAuth>()!.config;
  }

  @override
  bool updateShouldNotify(FTAuth old) => false;

  /// Sets up required configuration for using FTAuth.
  static Future<ftauth.FTAuthConfig> initFlutter(
      {ftauth.FTAuthConfig? config, String? configPath}) async {
    WidgetsFlutterBinding.ensureInitialized();

    // Try to load config from file if not provided.
    if (config == null) {
      configPath ??= _configPath;
      try {
        config = await rootBundle.loadStructuredData(configPath, (value) async {
          final configJson =
              (json.decode(value) as Map).cast<String, dynamic>();
          return ftauth.FTAuthConfig.fromJson(configJson);
        });
      } on Exception {
        throw ConfigNotFoundException(configPath);
      }
    }

    // Create a secure encryption key on mobile clients.
    Uint8List encryptionKey;
    const secureStorage = FlutterSecureStorage.instance;
    final storedEncryptionKey = await secureStorage.getData('key');
    if (storedEncryptionKey == null) {
      encryptionKey = Uint8List(32);
      fillRandomBytes(encryptionKey);
    } else {
      encryptionKey = storedEncryptionKey;
    }

    ftauth.CryptoRepo.instance = FlutterCryptoRepo();

    await ftauth.FTAuth.init(
      config!,
      encryptionKey: encryptionKey,
      authorizer: FlutterAuthorizer(config),
      storageRepo: FlutterSecureStorage.instance,
    );

    return config;
  }
}

extension AuthorizerX on ftauth.FTAuthConfig {
  /// A convenience method for mobile Flutter clients to login and retrieve
  /// an FTAuth client in one step.
  ///
  /// Flutter web and desktop applications must follow the two step process.
  Future<ftauth.Client> login() async {
    return (authorizer as FlutterAuthorizer).login();
  }
}
