import 'dart:typed_data';

import 'package:ftauth/ftauth.dart';
import 'package:http/http.dart' as http;

import 'authorizer_base.dart';

class Authorizer extends AuthorizerBase {
  Authorizer(
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
  Future<void> login({String? language, String? countryCode}) {
    // TODO: implement login
    throw UnimplementedError();
  }
}
