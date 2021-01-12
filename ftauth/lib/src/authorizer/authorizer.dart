import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:ftauth/ftauth.dart';
import 'package:ftauth/src/metadata/metadata_repo.dart';
import 'package:ftauth/src/metadata/metadata_repo_impl.dart';
import 'package:ftauth/src/model/user/user.dart';
import 'package:ftauth/src/storage/storage_repo.dart';
import 'package:jose/jose.dart';
import 'package:meta/meta.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:uuid/uuid.dart';

export 'authorizer_stub.dart'
    if (dart.library.io) 'authorizer_io.dart'
    if (dart.library.html) 'authorizer_html.dart';

abstract class Authorizer {
  final FTAuthConfig _config;
  final MetadataRepo _metadataRepo;
  final StorageRepo _storageRepo = StorageRepo.instance;

  final _authStateController = StreamController<AuthState>.broadcast();

  AuthState? _latestAuthState;
  Future<AuthState>? _initStateFuture;
  Stream<AuthState> get authState async* {
    if (_latestAuthState == null) {
      _initStateFuture ??= _initState();
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

  Authorizer(this._config) : _metadataRepo = MetadataRepoImpl(_config);

  // Platform-specific implementations

  @protected
  Future<void> launchUrl(String url) {
    throw UnimplementedError();
  }

  // Common implementations

  Future<AuthState> _initState() async {
    if (_initStateFuture != null) {
      return _initStateFuture!;
    }

    final accessToken = await _storageRepo.getString('access_token');
    final refreshToken = await _storageRepo.getString('refresh_token');

    if (accessToken != null && refreshToken != null) {
      final keyStore = await _metadataRepo.loadKeyStore();
      final access = await JsonWebToken.decodeAndVerify(accessToken, keyStore);
      final refresh =
          await JsonWebToken.decodeAndVerify(refreshToken, keyStore);

      print('Access claims: ${access.claims.toJson()}');
      print('Refresh claims: ${refresh.claims.toJson()}');

      if (access.claims.expiry.isAfter(DateTime.now()) ||
          refresh.claims.expiry.isAfter(DateTime.now())) {
        final credentials = Credentials(
          access,
          refresh,
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
      );

      // Generate URL to advance internal code grant state.
      final _ = _authCodeGrant!.getAuthorizationUrl(_config.redirectUri);
    }

    return AuthSignedOut();
  }

  Future<void> authorize() async {
    await (_initStateFuture ??= _initState());

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
      );
      final keyStore = await _metadataRepo.loadKeyStore();
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
    await _storageRepo.setString('state', state);

    final codeVerifier = oauth2.AuthorizationCodeGrant.createCodeVerifier();
    await _storageRepo.setString('code_verifier', codeVerifier);

    _authCodeGrant = oauth2.AuthorizationCodeGrant(
      _config.clientId,
      _config.authorizationUri,
      _config.tokenUri,
      codeVerifier: codeVerifier,
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
    await (_initStateFuture ??= _initState());

    if (_authCodeGrant == null) {
      throw StateError('Must call authorize first.');
    }

    _addState(const AuthLoading());

    final client =
        await _authCodeGrant!.handleAuthorizationResponse(parameters);
    final keyStore = await _metadataRepo.loadKeyStore();
    final credentials = await Credentials.fromOAuthCredentials(
      client.credentials,
      keyStore,
      _config.scopes,
    );

    await _storageRepo.setString('access_token', credentials.accessToken);
    await _storageRepo.setString('refresh_token', credentials.refreshToken);

    final newClient = Client(
      credentials: credentials,
      clientId: _config.clientId,
    );

    _addState(AuthSignedIn(newClient, credentials.user));

    await _storageRepo.deleteKey('state');
    await _storageRepo.deleteKey('code_verifier');

    return newClient;
  }
}
