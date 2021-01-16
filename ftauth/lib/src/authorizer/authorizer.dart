import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:ftauth/ftauth.dart';
import 'package:ftauth/src/dpop/dpop_repo.dart';
import 'package:ftauth/src/http/inline_client.dart';
import 'package:ftauth/src/jwt/token.dart';
import 'package:ftauth/src/metadata/metadata_repo.dart';
import 'package:ftauth/src/metadata/metadata_repo_impl.dart';
import 'package:ftauth/src/storage/storage_repo.dart';
import 'package:meta/meta.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:http/http.dart' as http;

import '../http/dpop_client.dart';

export 'authorizer_stub.dart'
    if (dart.library.io) 'authorizer_io.dart'
    if (dart.library.html) 'authorizer_html.dart';

abstract class Authorizer {
  final FTAuthConfig _config;
  final MetadataRepo _metadataRepo;
  final StorageRepo _storageRepo;

  final _authStateController = StreamController<AuthState>.broadcast();

  AuthState? _latestAuthState;

  /// Ensures that [_init()] is only called once.
  Future<AuthState>? _initStateFuture;

  /// Returns the stream of authorization states.
  ///
  /// Possible [AuthState] values include:
  /// * [AuthLoading]: Information is refreshing or being retrieved.
  /// * [AuthSignedIn]: User is logged in with valid credentials.
  /// * [AuthSignedOut]: User is logged out or has expired credentials.
  /// * [AuthFailure]: An error occurred during the login process.
  Stream<AuthState> get authStates async* {
    if (_latestAuthState == null) {
      _initStateFuture ??= init();
      _latestAuthState = await _initStateFuture!;
    }
    yield _latestAuthState!;
    yield* _authStateController.stream;
  }

  void _addState(AuthState state) {
    _latestAuthState = state;
    _authStateController.add(state);
  }

  oauth2.AuthorizationCodeGrant? _authCodeGrant;

  Authorizer(
    this._config, {
    StorageRepo? storageRepo,
    MetadataRepo? metadataRepo,
  })  : _metadataRepo = metadataRepo ?? MetadataRepoImpl(_config),
        _storageRepo = storageRepo ?? StorageRepo.instance;

  http.Client get _authClient {
    final baseClient = DPoPClient(DPoPRepo.instance);
    return InlineClient(
      send: (http.BaseRequest request) async {
        try {
          return await baseClient.send(request);
        } on Exception catch (e) {
          final state = AuthFailure('${e.runtimeType}', e.toString());
          _addState(state);
          throw AuthException(state.toString());
        }
      },
    );
  }

  // Platform-specific implementations

  @protected
  Future<void> launchUrl(String url) {
    throw UnimplementedError();
  }

  // Common implementations

  @visibleForTesting
  Future<AuthState> init() async {
    if (_initStateFuture != null) {
      return _initStateFuture!;
    }
    try {
      final accessTokenEnc = await _storageRepo.getString('access_token');
      final refreshTokenEnc = await _storageRepo.getString('refresh_token');

      if (accessTokenEnc != null && refreshTokenEnc != null) {
        final keyStore = await _metadataRepo.loadKeySet();
        final accessToken = JsonWebToken.parse(accessTokenEnc);
        accessToken.verify(keyStore);

        final refreshToken = JsonWebToken.parse(refreshTokenEnc);
        refreshToken.verify(keyStore);

        if (accessToken.claims.expiration!.isAfter(DateTime.now()) ||
            refreshToken.claims.expiration!.isAfter(DateTime.now())) {
          final credentials = Credentials(
            accessToken,
            refreshToken,
            _config.tokenUri,
            keyStore,
            _config.scopes,
          );
          final client = Client(
            credentials: credentials,
            clientId: _config.clientId,
          );

          return AuthSignedIn(client, credentials.user);
        } else {
          await _storageRepo.deleteKey('access_token');
          await _storageRepo.deleteKey('refresh_token');
        }
      }

      final state = await _storageRepo.getString('state');
      final codeVerifier = await _storageRepo.getString('code_verifier');

      if (state != null && codeVerifier != null) {
        _authCodeGrant = oauth2.AuthorizationCodeGrant(
          _config.clientId,
          _config.authorizationUri,
          _config.tokenUri,
          codeVerifier: codeVerifier,
          httpClient: _authClient,
        );

        // Generate URL to advance internal code grant state.
        final _ = _authCodeGrant!.getAuthorizationUrl(_config.redirectUri);
      }

      return AuthSignedOut();
    } catch (e) {
      return AuthFailure('${e.runtimeType}', e.toString());
    }
  }

  Future<void> authorize() async {
    await (_initStateFuture ??= init());

    if (_config.clientType == ClientType.confidential) {
      if (_config.clientSecret != null) {
        throw AssertionError(
            'Client secret must be provided for confidential clients.');
      }

      _addState(const AuthLoading());

      final client = await oauth2.clientCredentialsGrant(
        _config.authorizationUri,
        _config.clientId,
        _config.clientSecret!,
        scopes: _config.scopes,
        httpClient: _authClient,
      );
      final keyStore = await _metadataRepo.loadKeySet();
      final credentials = await Credentials.fromOAuthCredentials(
        client.credentials,
        keyStore,
        _config.scopes,
      );

      // Save keys to storage
      await _storageRepo.setString('access_token', credentials.accessToken);
      await _storageRepo.setString('refresh_token', credentials.refreshToken);

      final newClient = Client(
        credentials: credentials,
        clientId: _config.clientId,
        httpClient: _authClient,
      );

      _addState(AuthSignedIn(newClient, credentials.user));
    } else {
      _addState(const AuthLoading());

      final authorizationUrl = await getAuthorizationUrl();
      await launchUrl(authorizationUrl);
    }
  }

  String _generateState() {
    const _stateLength = 8;

    final random = Random.secure();
    final bytes = <int>[];
    for (var i = 0; i < _stateLength; i++) {
      final value = random.nextInt(255);
      bytes.add(value);
    }

    return base64Url.encode(bytes);
  }

  @visibleForTesting
  Future<String> getAuthorizationUrl() async {
    if (_config.clientType == ClientType.confidential) {
      throw StateError(
        'Confidential clients must use client credentials flow',
      );
    }

    final state = _generateState();
    final codeVerifier = oauth2.AuthorizationCodeGrant.createCodeVerifier();

    await _storageRepo.setString('state', state);
    await _storageRepo.setString('code_verifier', codeVerifier);

    _authCodeGrant = oauth2.AuthorizationCodeGrant(
      _config.clientId,
      _config.authorizationUri,
      _config.tokenUri,
      codeVerifier: codeVerifier,
      httpClient: _authClient,
    );
    return _authCodeGrant!
        .getAuthorizationUrl(
          _config.redirectUri,
          scopes: _config.scopes,
          state: state,
        )
        .toString();
  }

  Future<Client> exchangeAuthorizationCode(
      Map<String, String> parameters) async {
    await (_initStateFuture ??= init());

    if (_authCodeGrant == null) {
      throw StateError('Must call authorize first.');
    }

    _addState(const AuthLoading());

    final client =
        await _authCodeGrant!.handleAuthorizationResponse(parameters);
    final keyStore = await _metadataRepo.loadKeySet();
    final credentials = await Credentials.fromOAuthCredentials(
      client.credentials,
      keyStore,
      _config.scopes,
    );

    print('Got accessToken: ' + credentials.accessToken);
    print('Got refreshToken: ' + credentials.refreshToken);

    await _storageRepo.setString('access_token', credentials.accessToken);
    await _storageRepo.setString('refresh_token', credentials.refreshToken);

    final newClient = Client(
      credentials: credentials,
      clientId: _config.clientId,
      httpClient: _authClient,
    );

    _addState(AuthSignedIn(newClient, credentials.user));

    await _storageRepo.deleteKey('state');
    await _storageRepo.deleteKey('code_verifier');

    return newClient;
  }

  Future<void> logout() async {
    await _storageRepo.deleteKey('state');
    await _storageRepo.deleteKey('code_verifier');
    await _storageRepo.deleteKey('access_token');
    await _storageRepo.deleteKey('refresh_token');
    _addState(AuthSignedOut());
  }
}
