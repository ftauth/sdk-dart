import 'dart:async';

import 'package:ftauth/ftauth.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;

/// HTTP client which handles making authorized requests and automatically
/// refreshes access tokens when expired.
class Client extends http.BaseClient {
  /// Used to logout user on authorization failure (i.e. 401).
  final Authorizer _authorizer;

  /// Base HTTP client which handles automatic token refreshing and injection
  /// of credentials into HTTP headers.
  late final oauth2.Client _oauthClient;

  /// The authorized credentials for this client, including the
  /// access and refresh tokens and relevant metadata.
  Credentials credentials;

  /// Handles SSL pinning
  final SSLRepo _sslRepository;

  Client({
    required this.credentials,
    required String clientId,
    required SSLRepo sslRepository,
    required Authorizer authorizer,
    http.Client? httpClient,
    Duration? timeout,
  })  : _authorizer = authorizer,
        _sslRepository = sslRepository {
    final sslPinningClient = SSLPinningClient(
      _sslRepository,
      baseClient: httpClient,
      timeout: timeout,
    );
    _oauthClient = oauth2.Client(
      credentials,
      identifier: clientId,
      httpClient: sslPinningClient,
    );
  }

  @override
  Future<http.StreamedResponse> send(
    http.BaseRequest request, {
    int retries = 1,
  }) async {
    while (true) {
      try {
        return await _oauthClient.send(request);
      } on oauth2.AuthorizationException {
        if (retries > 0) {
          retries--;
          continue;
        }
        FTAuth.info('Request returned 401. Logging out...');
        await _authorizer.logout();
        rethrow;
      }
    }
  }
}
