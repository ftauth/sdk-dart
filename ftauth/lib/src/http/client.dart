import 'dart:async';

import 'package:ftauth/ftauth.dart';
import 'package:ftauth/src/credentials.dart';
import 'package:ftauth/src/dpop/dpop_repo.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'dpop_client.dart';

class Client extends http.BaseClient {
  final oauth2.Client _httpClient;

  /// The authorized credentials for this client, including the
  /// access and refresh tokens and relevant metadata.
  final Credentials credentials;

  Client({
    required this.credentials,
    required String clientId,
  }) : _httpClient = oauth2.Client(
          credentials,
          identifier: clientId,
          httpClient: DPoPClient(DPoPRepo.instance),
        );

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _httpClient.send(request);
  }
}
