import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ftauth/ftauth.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uni_links/uni_links.dart';

import 'exception.dart';
import 'flutter_authorizer.dart';

const _configPath = 'assets/config.json';

Future<void> initFlutter({Config config, String configPath}) async {
  // Try to load config from file if not provided.
  if (config == null) {
    configPath ??= _configPath;
    try {
      config = await rootBundle.loadStructuredData(configPath, (value) async {
        final configJson = (json.decode(value) as Map).cast<String, dynamic>();
        return Config.fromJson(configJson);
      });
    } on Exception {
      throw ConfigNotFoundException(configPath);
    }
  }

  await Hive.initFlutter();

  // Create a secure encryption key on mobile clients.
  Uint8List encryptionKey;
  if (!kIsWeb) {
    final secureStorage = const FlutterSecureStorage();
    var containsEncryptionKey = await secureStorage.containsKey(key: 'key');
    if (containsEncryptionKey) {
      final encodedKey = await secureStorage.read(key: 'key');
      encryptionKey = base64Url.decode(encodedKey);
    } else {
      encryptionKey = Hive.generateSecureKey();
      await secureStorage.write(
          key: 'key', value: base64Url.encode(encryptionKey));
    }
  }

  return FTAuth.instance.init(
    config,
    encryptionKey: encryptionKey,
    authorizer: FlutterAuthorizer(config),
  );
}

extension AuthorizerX on Config {
  /// A convenience method for mobile Flutter clients to login and retrieve
  /// an FTAuth client in one step.
  ///
  /// Flutter web and desktop applications must follow the two step process.
  Future<Client> login() async {
    if (kIsWeb) {
      throw AssertionError(
          'login should only be called for Flutter mobile clients. '
          'All other clients (web/desktop) should use authorize, followed by '
          'exchangeAuthorizationCode.');
    }
    await authorizer.authorize();

    final redirect = await getLinksStream().firstWhere(
      (url) => url.startsWith(redirectUri.toString()),
    );

    final queryParams = Uri.parse(redirect).queryParameters;

    return authorizer.exchangeAuthorizationCode(queryParams);
  }
}
