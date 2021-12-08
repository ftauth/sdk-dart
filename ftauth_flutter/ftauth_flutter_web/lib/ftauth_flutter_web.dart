import 'dart:typed_data';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:ftauth/ftauth.dart';
import 'package:http/http.dart' as http;
import 'package:ftauth_flutter_platform_interface/ftauth_flutter_platform_interface.dart';

/// A web implementation of the FTAuthFlutter plugin.
class FTAuthFlutterWeb extends FTAuthPlatform {
  static void registerWith(Registrar registrar) {
    FTAuthPlatform.instance = FTAuthFlutterWeb();
  }

  @override
  void createAuthorizer(
    Config config, {
    required StorageRepo storageRepo,
    SSLRepo? sslRepository,
    http.Client? baseClient,
    Duration? timeout,
    Uint8List? encryptionKey,
    bool? clearOnFreshInstall,
  }) {
    authorizer = AuthorizerImpl(
      config,
      storageRepo: storageRepo,
      sslRepository: sslRepository,
      baseClient: baseClient,
      timeout: timeout,
      encryptionKey: encryptionKey,
      clearOnFreshInstall: clearOnFreshInstall,
    );
  }
}
