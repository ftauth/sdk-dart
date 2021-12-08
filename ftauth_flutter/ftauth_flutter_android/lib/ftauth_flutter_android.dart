import 'dart:typed_data';

import 'package:ftauth/ftauth.dart';
import 'package:ftauth/src/authorizer/keys.dart';
import 'package:http/http.dart' as http;
import 'package:ftauth_flutter_platform_interface/ftauth_flutter_platform_interface.dart';

class _AndroidAuthorizer extends AuthorizerImpl {
  _AndroidAuthorizer(
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

  static final _nativeLogin = NativeLogin();

  @override
  Future<void> login({
    String? language,
    String? countryCode,
  }) async {
    final url = await authorize(
      language: language,
      countryCode: countryCode,
    );

    final state = await storageRepo.getString(keyState);
    final codeVerifier = await storageRepo.getString(keyCodeVerifier);

    FTAuth.debug('Launching url: $url');
    final clientConfiguration = createClientConfiguration(
      config,
      state: state!,
      codeVerifier: codeVerifier!,
    );
    final Map<String, String> parameters =
        (await _nativeLogin.login(clientConfiguration)).cast();

    await exchange(parameters);
  }
}

class FTAuthFlutterAndroid extends FTAuthPlatform {
  /// Registers this class as the default instance of [FTAuthPlatform]
  static void registerWith() {
    FTAuthPlatform.instance = FTAuthFlutterAndroid();
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
    authorizer = _AndroidAuthorizer(
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
