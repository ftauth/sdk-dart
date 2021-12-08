import 'dart:typed_data';

import 'package:ftauth/ftauth.dart';
import 'package:http/http.dart' as http;

class AuthorizerImpl extends Authorizer {
  AuthorizerImpl(
    Config config, {
    required StorageRepo storageRepo,
    SSLRepo? sslRepository,
    http.Client? baseClient,
    Duration? timeout,
    Uint8List? encryptionKey,
    bool? clearOnFreshInstall,
  }) : super(
          config,
          storageRepo: storageRepo,
          sslRepository: sslRepository,
          baseClient: baseClient,
          timeout: timeout,
          encryptionKey: encryptionKey,
          clearOnFreshInstall: clearOnFreshInstall,
        );

  @override
  Future<void> launchUrl(String url) {
    throw UnimplementedError();
  }

  @override
  Future<void> login({String? language, String? countryCode}) {
    throw UnimplementedError();
  }
}
