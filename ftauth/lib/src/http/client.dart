import 'dart:async';
import 'dart:convert';

import 'package:crypto_keys/crypto_keys.dart';
import 'package:ftauth/ftauth.dart';
import 'package:ftauth/src/credentials.dart';
import 'package:ftauth/src/crypto/crypto_repo.dart';
import 'package:ftauth/src/dpop/dpop_repo_impl.dart';
import 'package:ftauth/src/storage/storage_repo.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:jose/jose.dart';
import 'package:uuid/uuid.dart';

import '../model/state/auth_state.dart';
import 'dpop_client.dart';

class Client extends http.BaseClient {
  final StreamController<AuthState> _authStateController =
      StreamController<AuthState>();
  final oauth2.Client _httpClient;
  static final _dpopHttpClient =
      DPoPHttpClient(DPoPRepoImpl(CryptoRepoImpl(FTAuth.instance.storageRepo)));

  /// The authorized credentials for this client, including the
  /// access and refresh tokens and relevant metadata.
  final Credentials credentials;

  Client({
    required this.credentials,
  }) : _httpClient = oauth2.Client(
          credentials,
          httpClient: _dpopHttpClient,
        );

  Stream<AuthState> get authState => _authStateController.stream;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _httpClient.send(request);
  }
}
