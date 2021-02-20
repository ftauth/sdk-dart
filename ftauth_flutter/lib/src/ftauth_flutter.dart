import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:ftauth/ftauth.dart' as ftauth;
import 'package:ftauth_flutter/src/storage/secure_storage.dart';

import 'exception.dart';
import 'flutter_authorizer.dart';

/// The default configuration path.
const kConfigPath = 'assets/ftauth_config.json';

extension FTAuthFlutter on ftauth.FTAuthImpl {
  /// Initializes the FTAuth instance.
  ///
  /// Must be called before any other methods are called. Typically, this is
  /// done in the main method, before all Flutter actions.
  ///
  /// ```
  /// Future<void> main() async {
  ///   final config = FTAuthConfig(
  ///     gatewayUrl: 'https://7602aa8d005e.ngrok.io',
  ///     clientId: '3cf9a7ac-9198-469e-92a7-cc2f15d8b87d',
  ///     clientType: ClientType.public,
  ///     redirectUri: kIsWeb ? 'http://localhost:8080/#/auth' : 'myapp://auth',
  ///   );
  ///
  ///   await FTAuth.initFlutter(config: config);
  ///
  ///   runApp(MyApp());
  /// }
  /// ```
  Future<void> initFlutter({
    ftauth.FTAuthConfig? config,
    String? configPath,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();

    // Try to load config from file if not provided.
    if (config == null) {
      configPath ??= kConfigPath;
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
    final cryptoRepo = ftauth.CryptoRepoImpl(secureStorage);
    final storedEncryptionKey = await secureStorage.getData('key');
    if (storedEncryptionKey == null) {
      encryptionKey = cryptoRepo.secureRandom.nextBytes(32);
    } else {
      encryptionKey = storedEncryptionKey;
    }

    ftauth.CryptoRepo.instance = cryptoRepo;

    return ftauth.FTAuth.init(
      config!,
      encryptionKey: encryptionKey,
      authorizer: FlutterAuthorizer(config),
      storageRepo: secureStorage,
    );
  }

  /// A convenience method for mobile Flutter clients to login and retrieve
  /// an FTAuth client in one step.
  ///
  /// Flutter Web applications must still call [exchange] after being redirected.
  Future<ftauth.Client> login() async {
    return (authorizer as FlutterAuthorizer).login();
  }
}
