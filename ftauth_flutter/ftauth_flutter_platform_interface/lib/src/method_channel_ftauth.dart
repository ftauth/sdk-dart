import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:ftauth/ftauth.dart';
import 'package:http/http.dart' as http;
import 'package:ftauth_flutter_platform_interface/ftauth_flutter_platform_interface.dart';

class _MethodChannelAuthorizer extends AuthorizerImpl {
  _MethodChannelAuthorizer(
    Config config, {
    required StorageRepo storageRepo,
    SSLRepo? sslRepository,
    http.Client? baseClient,
    Duration? timeout,
    Uint8List? encryptionKey,
    bool? clearOnFreshInstall,
    required ConfigChangeStrategy configChangeStrategy,
  }) : super(
          config,
          storageRepo: storageRepo,
          sslRepository: sslRepository,
          baseClient: baseClient,
          timeout: timeout,
          encryptionKey: encryptionKey,
          clearOnFreshInstall: clearOnFreshInstall,
          configChangeStrategy: configChangeStrategy,
        );

  static const _channel = MethodChannel('ftauth_flutter');

  @override
  Future<void> login({
    String? language,
    String? countryCode,
  }) async {
    final url = await authorize(
      language: language,
      countryCode: countryCode,
    );

    FTAuth.debug('Launching url: $url');
    final Map<String, String>? parameters =
        await _channel.invokeMapMethod<String, String>('login', url);

    if (parameters == null) {
      throw PlatformException(
        code: PlatformExceptionCodes.unknown,
        message: 'Login process failed.',
      );
    }

    await exchange(parameters);
  }
}

class MethodChannelFTAuth extends FTAuthPlatform {
  @override
  void createAuthorizer(
    Config config, {
    required StorageRepo storageRepo,
    SSLRepo? sslRepository,
    http.Client? baseClient,
    Duration? timeout,
    Uint8List? encryptionKey,
    bool? clearOnFreshInstall,
    required ConfigChangeStrategy configChangeStrategy,
  }) {
    authorizer = _MethodChannelAuthorizer(
      config,
      storageRepo: storageRepo,
      sslRepository: sslRepository,
      baseClient: baseClient,
      timeout: timeout,
      encryptionKey: encryptionKey,
      clearOnFreshInstall: clearOnFreshInstall,
      configChangeStrategy: configChangeStrategy,
    );
  }
}
