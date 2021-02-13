import 'dart:async';

import 'package:ftauth/ftauth.dart';
import 'package:ftauth/src/credentials.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;

class Client extends http.BaseClient {
  final oauth2.Client _oauthClient;

  /// The authorized credentials for this client, including the
  /// access and refresh tokens and relevant metadata.
  final Credentials credentials;

  Client({
    required this.credentials,
    required String clientId,
    http.Client? httpClient,
  }) : _oauthClient = oauth2.Client(
          credentials,
          identifier: clientId,
          httpClient: httpClient,
        );

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _oauthClient.send(request);
  }
}
