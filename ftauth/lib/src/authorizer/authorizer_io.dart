import 'dart:io';
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
  Future<void> launchUrl(String url) async {
    FTAuth.info('Open the following url: $url');
  }

  @override
  Future<void> login({
    String? language,
    String? countryCode,
  }) async {
    await init();

    // final bool isLocalhost =
    //     InternetAddress.tryParse(config.redirectUri.host) ==
    //             InternetAddress.loopbackIPv4 ||
    //         config.redirectUri.host == 'localhost';

    // if (!isLocalhost) {
    //   throw ArgumentError('Use authorize/exchange instead');
    // }

    final listenServer = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      0,
    );
    try {
      final Uri localRedirectUri = Uri(
        scheme: 'http',
        host: 'localhost',
        port: listenServer.port,
      );
      final authUrl = await getAuthorizationUrl(
        language: language,
        countryCode: countryCode,
        redirectUri: localRedirectUri,
      );
      await launchUrl(authUrl);

      late Map<String, String> queryParams;
      await for (var request in listenServer) {
        var method = request.method;
        if (method != 'GET') {
          request.response.statusCode = HttpStatus.methodNotAllowed;
          request.response.writeln('Request must be GET');
          await request.response.flush();
          await request.response.close();
          continue;
        }
        queryParams = request.uri.queryParameters;
        if (queryParams.containsKey('code') ||
            queryParams.containsKey('error')) {
          if (!queryParams.containsKey('state')) {
            request.response.statusCode = HttpStatus.badRequest;
            request.response.writeln('Missing "state" parameter');
            await request.response.flush();
            await request.response.close();
            continue;
          }
        }
        request.response.statusCode = HttpStatus.ok;
        request.response.writeln('Success! You can now close this window.');
        await request.response.flush();
        await request.response.close();
        break;
      }

      await exchange(queryParams);
    } on Exception catch (e) {
      addState(AuthFailure.fromException(e));
      rethrow;
    } finally {
      await listenServer.close(force: true);
    }
  }
}
