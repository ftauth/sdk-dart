import 'dart:async';
import 'dart:math';

import 'package:ftauth/ftauth.dart';
import 'package:ftauth/src/dpop/dpop_repo.dart';
import 'package:ftauth/src/http/inline_client.dart';
import 'package:ftauth/src/jwt/token.dart';
import 'package:ftauth/src/jwt/util.dart';
import 'package:ftauth/src/metadata/metadata_repo.dart';
import 'package:ftauth/src/metadata/metadata_repo_impl.dart';
import 'package:ftauth/src/storage/storage_repo.dart';
import 'package:ftauth/src/crypto/crypto_key.dart';
import 'package:ftauth/src/user/user_repo.dart';
import 'package:meta/meta.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:http/http.dart' as http;

import '../http/dpop_client.dart';
import 'keys.dart';

class Authorizer {
  final FTAuthConfig _config;
  late final MetadataRepo _metadataRepo;
  late final http.Client? _baseClient;
  final StorageRepo _storageRepo;

  final _authStateController = StreamController<AuthState>.broadcast();

  AuthState? _latestAuthState;

  /// Ensures that `_init` is only called once.
  Future<AuthState>? _initStateFuture;

  /// Returns the stream of authorization states.
  ///
  /// Possible [AuthState] values include:
  /// * [AuthLoading]: Information is refreshing or being retrieved.
  /// * [AuthSignedIn]: User is logged in with valid credentials.
  /// * [AuthSignedOut]: User is logged out or has expired credentials.
  /// * [AuthFailure]: An error has occurred during authentication or during an HTTP request.
  Stream<AuthState> get authStates async* {
    if (_latestAuthState == null) {
      _initStateFuture ??= _init();
      _latestAuthState = await _initStateFuture!;
    }
    yield _latestAuthState!;
    yield* _authStateController.stream;
  }

  void _addState(AuthState state) {
    _latestAuthState = state;
    _authStateController.add(state);
  }

  void _onRefreshError(dynamic e) {
    if (e is http.ClientException) {
      e = ApiException('', e.uri.toString(), 0, e.message);
    }
    _addState(AuthFailure.fromException(e));
  }

  oauth2.AuthorizationCodeGrant? _authCodeGrant;

  Authorizer(
    this._config, {
    StorageRepo? storageRepo,
    MetadataRepo? metadataRepo,
    http.Client? baseClient,
  }) : _storageRepo = storageRepo ?? StorageRepo.instance {
    _baseClient = baseClient;
    _metadataRepo = metadataRepo ?? MetadataRepoImpl(_config, httpClient);
  }

  http.Client get httpClient {
    final baseClient = _baseClient ?? DPoPClient(DPoPRepo.instance);
    return InlineClient(
      send: (http.BaseRequest request) async {
        Exception? _e;
        try {
          return await baseClient.send(request);
        } on http.ClientException catch (e) {
          _e = e;
          throw ApiException(
            request.method,
            request.url.toString(),
            0,
            e.toString(),
          );
        } on Exception catch (e) {
          _e = e;
          rethrow;
        } finally {
          if (_e != null) {
            final state = AuthFailure.fromException(_e);
            _addState(state);
          }
        }
      },
    );
  }

  Future<AuthState> _init() async {
    if (_initStateFuture != null) {
      return _initStateFuture!;
    }
    try {
      final accessTokenEnc = await _storageRepo.getString(keyAccessToken);
      final refreshTokenEnc = await _storageRepo.getString(keyRefreshToken);

      if (accessTokenEnc != null && refreshTokenEnc != null) {
        final keyStore = await _metadataRepo.loadKeySet();
        final accessToken = JsonWebToken.parse(accessTokenEnc);
        await accessToken.verify(
          keyStore,
          verifierFactory: (key) => key.verifier,
        );

        final refreshToken = JsonWebToken.parse(refreshTokenEnc);
        await refreshToken.verify(
          keyStore,
          verifierFactory: (key) => key.verifier,
        );

        if (accessToken.claims.expiration!.isAfter(DateTime.now()) ||
            refreshToken.claims.expiration!.isAfter(DateTime.now())) {
          final credentials = Credentials(
            accessToken,
            refreshToken,
            _config.tokenUri,
            keyStore,
            _config.scopes,
            onError: _onRefreshError,
          );
          final client = Client(
            credentials: credentials,
            clientId: _config.clientId,
            httpClient: httpClient,
          );

          final userId = accessToken.claims.ftauthClaims!['user_id'] as String;
          final user = await UserRepo(_config, client).getUserInfo(userId);

          return AuthSignedIn(client, user);
        } else {
          await _storageRepo.delete(keyAccessToken);
          await _storageRepo.delete(keyRefreshToken);
        }
      }

      final state = await _storageRepo.getString(keyState);
      final codeVerifier = await _storageRepo.getString(keyCodeVerifier);

      if (state != null && codeVerifier != null) {
        _authCodeGrant = oauth2.AuthorizationCodeGrant(
          _config.clientId,
          _config.authorizationUri,
          _config.tokenUri,
          secret: '',
          codeVerifier: codeVerifier,
          httpClient: httpClient,
        );

        // Generate URL to advance internal code grant state.
        final _ = _authCodeGrant!.getAuthorizationUrl(_config.redirectUri);
      }

      return AuthSignedOut();
    } catch (e) {
      return AuthFailure('${e.runtimeType}', e.toString());
    }
  }

  Future<Client> loginWithUsernameAndPassword(
    String username,
    String password,
  ) async {
    _addState(const AuthLoading());

    final client = await oauth2.resourceOwnerPasswordGrant(
      _config.authorizationUri,
      username,
      password,
      identifier: _config.clientId,
      secret: _config.clientSecret ?? '',
      scopes: _config.scopes,
      httpClient: httpClient,
    );

    final keyStore = await _metadataRepo.loadKeySet();
    final credentials = await Credentials.fromOAuthCredentials(
      client.credentials,
      keyStore,
      _config.scopes,
      onError: _onRefreshError,
    );

    await _storageRepo.setString(keyAccessToken, credentials.accessToken);
    await _storageRepo.setString(keyRefreshToken, credentials.refreshToken);

    final newClient = Client(
      credentials: credentials,
      clientId: _config.clientId,
      httpClient: httpClient,
    );

    final accessToken = JsonWebToken.parse(client.credentials.accessToken);
    final userId = accessToken.claims.ftauthClaims!['user_id'] as String;
    final user = await UserRepo(_config, newClient).getUserInfo(userId);

    _addState(AuthSignedIn(newClient, user));

    return newClient;
  }

  Future<Client> loginWithCredentials() async {
    if (_config.clientType == ClientType.public) {
      throw AssertionError(
          'Public clients should call authorize, followed by exchange.');
    }
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
      httpClient: httpClient,
    );
    final keyStore = await _metadataRepo.loadKeySet();
    final credentials = await Credentials.fromOAuthCredentials(
      client.credentials,
      keyStore,
      _config.scopes,
      onError: _onRefreshError,
    );

    // Save keys to storage
    await _storageRepo.setString(keyAccessToken, credentials.accessToken);
    await _storageRepo.setString(keyRefreshToken, credentials.refreshToken);

    final newClient = Client(
      credentials: credentials,
      clientId: _config.clientId,
      httpClient: httpClient,
    );

    _addState(AuthSignedIn(newClient, null));

    return newClient;
  }

  Future<String> authorize() async {
    await (_initStateFuture ??= _init());

    _addState(const AuthLoading());
    return getAuthorizationUrl();
  }

  String _generateState() {
    const _stateLength = 16;

    final random = Random.secure();
    final bytes = <int>[];
    for (var i = 0; i < _stateLength; i++) {
      final value = random.nextInt(255);
      bytes.add(value);
    }

    return base64RawUrl.encode(bytes);
  }

  String _createCodeVerifier() {
    const length = 128;
    const characterSet =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~';
    var codeVerifier = '';
    for (var i = 0; i < length; i++) {
      codeVerifier +=
          characterSet[Random.secure().nextInt(characterSet.length)];
    }
    return codeVerifier;
  }

  @visibleForTesting
  Future<String> getAuthorizationUrl() async {
    if (_config.clientType == ClientType.confidential) {
      throw StateError(
        'Confidential clients must use client credentials flow',
      );
    }

    final state = _generateState();
    final codeVerifier = _createCodeVerifier();

    await _storageRepo.setString(keyState, state);
    await _storageRepo.setString(keyCodeVerifier, codeVerifier);

    _authCodeGrant = oauth2.AuthorizationCodeGrant(
      _config.clientId,
      _config.authorizationUri,
      _config.tokenUri,
      secret: '',
      codeVerifier: codeVerifier,
      httpClient: httpClient,
    );
    return _authCodeGrant!
        .getAuthorizationUrl(
          _config.redirectUri,
          scopes: _config.scopes,
          state: state,
        )
        .toString();
  }

  AuthFailure _buildError(String? error, {required String code, String? uri}) {
    return AuthFailure(
      code,
      error ?? '' + (uri == null ? '' : '\nFor more information, visit $uri'),
    );
  }

  Future<Client> exchange(Map<String, String> parameters) async {
    await (_initStateFuture ??= _init());

    if (_authCodeGrant == null) {
      throw StateError('Must call authorize first.');
    }

    if (parameters.containsKey('error')) {
      final error = parameters['error']!;
      final errorDesc = parameters['error_description'];
      final errorUri = parameters['error_uri'];
      _addState(_buildError(errorDesc, code: error, uri: errorUri));
      throw AuthException(error);
    }

    _addState(const AuthLoading());

    try {
      final client =
          await _authCodeGrant!.handleAuthorizationResponse(parameters);
      final keyStore = await _metadataRepo.loadKeySet();
      final accessToken = JsonWebToken.parse(client.credentials.accessToken);
      final userId = accessToken.claims.ftauthClaims!['user_id'] as String;

      final credentials = await Credentials.fromOAuthCredentials(
        client.credentials,
        keyStore,
        _config.scopes,
        onError: _onRefreshError,
      );

      await _storageRepo.setString(keyAccessToken, credentials.accessToken);
      await _storageRepo.setString(keyRefreshToken, credentials.refreshToken);

      final newClient = Client(
        credentials: credentials,
        clientId: _config.clientId,
        httpClient: httpClient,
      );

      final user = await UserRepo(_config, newClient).getUserInfo(userId);

      _addState(AuthSignedIn(newClient, user));

      await _storageRepo.delete(keyState);
      await _storageRepo.delete(keyCodeVerifier);

      return newClient;
    } catch (e) {
      _addState(AuthFailure('${e.runtimeType}', e.toString()));
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storageRepo.delete(keyState);
    await _storageRepo.delete(keyCodeVerifier);
    await _storageRepo.delete(keyAccessToken);
    await _storageRepo.delete(keyRefreshToken);
    _addState(AuthSignedOut());
  }
}
