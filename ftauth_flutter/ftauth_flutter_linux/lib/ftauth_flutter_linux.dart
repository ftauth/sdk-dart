import 'dart:typed_data';

import 'package:ftauth/ftauth.dart';
import 'package:ftauth_flutter_platform_interface/ftauth_flutter_platform_interface.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class _LinuxAuthorizer extends AuthorizerImpl {
  _LinuxAuthorizer(
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

  @override
  Future<void> launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}

class FTAuthFlutterLinux extends FTAuthPlatform {
  /// Registers this class as the default instance of [FTAuthPlatform]
  static void registerWith() {
    FTAuthPlatform.instance = FTAuthFlutterLinux();
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
    required ConfigChangeStrategy configChangeStrategy,
  }) {
    authorizer = _LinuxAuthorizer(
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
