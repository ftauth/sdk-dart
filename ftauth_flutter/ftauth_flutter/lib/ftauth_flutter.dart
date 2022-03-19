library ftauth_flutter;

export 'package:ftauth/ftauth.dart' hide FTAuth;
export 'package:ftauth_storage/ftauth_storage.dart';

export 'src/ftauth_flutter.dart';
export 'src/widget/embedded_login_view.dart';
export 'src/widget/login_error_popup_view.dart';
import 'dart:typed_data';

import 'package:ftauth/ftauth.dart';
import 'package:ftauth_flutter_platform_interface/ftauth_flutter_platform_interface.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class _DesktopAuthorizer extends AuthorizerImpl {
  _DesktopAuthorizer(
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

class FTAuthFlutterDesktop extends FTAuthPlatform {
  static void registerWith() {
    FTAuthPlatform.instance = FTAuthFlutterDesktop();
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
    authorizer = _DesktopAuthorizer(
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
