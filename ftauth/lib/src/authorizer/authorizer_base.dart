import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:ftauth/ftauth.dart';
import 'package:ftauth/src/http/inline_client.dart';
import 'package:meta/meta.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:http/http.dart' as http;

import 'keys.dart';

/// Handles the generic OAuth flow by interfacing with native layer components and
/// maintaining the state of the client.
abstract class AuthorizerBase
    implements AuthorizerInterface, SSLPinningInterface {
  /// The configuration for this authorizer. This may be updated throughout the
  /// OAuth flow as new information is available.
  final Config config;

  /// The base client to use for internal HTTP calls.
  late final http.Client _baseClient;

  /// Stores client-sensitive information related to the OAuth flow. Must be
  /// persistent, so that state can be recovered on startup.
  final StorageRepo _storageRepo;

  /// Encryption key used for [_storageRepo].
  final Uint8List? _encryptionKey;

  /// Whether to clear previous Keychain items on a fresh install.
  final bool clearOnFreshInstall;

  /// Stores pinned SSL certificates.
  final SSLRepo _sslRepository;

  final _authStateController = StreamController<AuthState>.broadcast();

  /// The cached auth state.
  AuthState? _latestAuthState;

  /// The current auth state.
  @override
  AuthState get currentState => _latestAuthState ?? const AuthLoading();

  /// Ensures that [init] is only called once.
  Future<AuthState>? _initStateFuture;

  /// Returns the stream of authorization states.
  Stream<AuthState> get authStates async* {
    await init();
    yield _latestAuthState!;
    yield* _authStateController.stream;
  }

  /// Adds the state to the stream and caches it.
  @protected
  void addState(AuthState state) {
    if (state != _latestAuthState) {
      FTAuth.debug('Next state: $state');
      _latestAuthState = state;
      _authStateController.add(state);
    }
  }

  /// Internal representation of the OAuth flow.
  oauth2.AuthorizationCodeGrant? _authCodeGrant;

  AuthorizerBase(
    this.config, {
    required StorageRepo storageRepo,
    SSLRepo? sslRepository,
    http.Client? baseClient,
    Duration? timeout,
    Uint8List? encryptionKey,
    bool? clearOnFreshInstall,
  })  : _storageRepo = storageRepo,
        _sslRepository = sslRepository ?? SSLRepoImpl(storageRepo),
        _encryptionKey = encryptionKey,
        clearOnFreshInstall = clearOnFreshInstall ?? true {
    _baseClient = SSLPinningClient(
      _sslRepository,
      baseClient: baseClient,
      timeout: timeout,
    );
  }

  /// Handles internal HTTP requests.
  http.Client get _httpClient {
    return InlineClient(
      send: (http.BaseRequest request) async {
        Exception? _e;
        try {
          return await _baseClient.send(request);
        } on http.ClientException catch (e) {
          _e = e;
          throw ApiException(request.method, request.url, 0, e.toString());
        } on Exception catch (e) {
          _e = e;
          rethrow;
        } finally {
          if (_e != null) {
            final state = AuthFailure.fromException(_e);
            addState(state);
          }
        }
      },
    );
  }

  /// Initializes the SDK and guarantees that [_init] is only called once.
  @override
  Future<void> init() async {
    if (_latestAuthState == null) {
      _initStateFuture ??= _init().then((state) {
        FTAuth.debug('Initial state: $state');
        return state;
      });
      _latestAuthState = await _initStateFuture!;
    }
  }

  /// Initializes the SDK with no assumptions. Checks what is stored on disk
  /// to determine the state of the client.
  Future<AuthState> _init() async {
    if (_initStateFuture != null) {
      return _initStateFuture!;
    }

    FTAuth.debug('Inititalizing SSO module...');

    await _storageRepo.init(encryptionKey: _encryptionKey);

    // Checks if this is the first time starting the app from a fresh install.
    // If it is, clear any old Keychain information which may be left behind
    // from previous installs.
    final isFreshInstall =
        await _storageRepo.getEphemeralString(keyFreshInstall) == null;
    if (isFreshInstall && clearOnFreshInstall) {
      FTAuth.debug('Clearing old Keychain items...');
      await _storageRepo.clear();
      await _storageRepo.setEphemeralString(keyFreshInstall, 'flag');
    }

    // Initialize the SSL repository
    await _sslRepository.init();

    // Store locally the current config
    await _storageRepo.setString(keyConfig, jsonEncode(config));

    try {
      final stateFromStorage = await _reloadFromStorage();
      if (stateFromStorage != null) {
        return stateFromStorage;
      }

      final state = await _storageRepo.getString(keyState);
      final codeVerifier = await _storageRepo.getString(keyCodeVerifier);

      if (state != null && codeVerifier != null) {
        FTAuth.debug('State and code verifier found. Logging out.');
        await _clearStorageForLogout();
      }

      FTAuth.info('User is logged out.');

      return const AuthSignedOut();
    } catch (e) {
      return AuthFailure('${e.runtimeType}', e.toString());
    }
  }

  /// Reloads the current AuthState from storage, if present.
  Future<AuthState?> _reloadFromStorage() async {
    FTAuth.debug('Reloading tokens from storage...');
    final accessTokenEnc = await _storageRepo.getString(keyAccessToken);
    final refreshTokenEnc = await _storageRepo.getString(keyRefreshToken);
    final idTokenEnc = await _storageRepo.getString(keyIdToken);

    if (accessTokenEnc == null) {
      FTAuth.debug('No tokens found in storage.');
      return null;
    }

    final accessToken = Token(
      accessTokenEnc,
      type: config.accessTokenFormat,
    );

    Token? refreshToken;
    if (refreshTokenEnc != null) {
      refreshToken = Token(
        refreshTokenEnc,
        type: config.refreshTokenFormat,
      );
    }

    Token? idToken;
    if (idTokenEnc != null) {
      idToken = Token(
        idTokenEnc,
        type: TokenFormat.jwt,
      );
    }

    var credentials = Credentials(
      accessToken,
      refreshToken,
      config,
      idToken: idToken,
      storageRepo: _storageRepo,
      httpClient: _httpClient,
    );

    if (accessToken.expiry == null || accessToken.isExpired) {
      try {
        credentials = await credentials.refresh() as Credentials;
      } on oauth2.AuthorizationException {
        FTAuth.info('Could not refresh access token. Logging user out...');
        await _clearStorageForLogout();
        return const AuthSignedOut();
      }
    }

    final client = Client(
      credentials: credentials,
      clientId: config.clientId,
      sslRepository: _sslRepository,
      authorizer: this,
      httpClient: _baseClient,
    );

    User? user;
    try {
      user = await UserRepo(config, client, _storageRepo).getUserInfo();
    } on Exception catch (e) {
      FTAuth.error('Error downloading user: $e');
    }

    FTAuth.info('User is logged in.');

    return AuthSignedIn(client, user);
  }

  /// Pull the latest auth state from the keychain. If, for example, an app extension
  /// refreshed it, we may not have the latest.
  Future<void> refreshAuthState() async {
    final state = await _reloadFromStorage();
    if (state != null) {
      // Only update the credentials when refreshing. Otherwise, add new states
      // to the stream.
      if (_latestAuthState is AuthSignedIn && state is AuthSignedIn) {
        (_latestAuthState as AuthSignedIn).client.credentials =
            state.client.credentials;
      } else {
        addState(state);
      }
    }
  }

  /// Initiates the authorization code flow.
  @override
  Future<String> authorize({
    String? language,
    String? countryCode,
  }) async {
    await init();
    if (_latestAuthState is AuthSignedIn) {
      FTAuth.info('User is already logged in.');
      return '';
    }
    addState(const AuthLoading());
    return getAuthorizationUrl(
      language: language,
      countryCode: countryCode,
    );
  }

  /// Returns the URL to direct the user to via a WebView.
  ///
  /// Classes which extend [Authorizer] may override this method.
  @protected
  @visibleForTesting
  @mustCallSuper
  Future<String> getAuthorizationUrl({
    String? language,
    String? countryCode,
    Uri? redirectUri,
  }) async {
    if (config.clientType == ClientType.confidential) {
      throw StateError(
        'Confidential clients must use client credentials flow',
      );
    }

    final state = OAuthUtil.generateState();
    final codeVerifier = OAuthUtil.createCodeVerifier();

    await Future.wait([
      _storageRepo.setString(keyState, state),
      _storageRepo.setString(keyCodeVerifier, codeVerifier),
    ]);

    _authCodeGrant = oauth2.AuthorizationCodeGrant(
      config.clientId,
      config.authorizationUri,
      config.tokenUri,
      // Must be included as empty string so that the client ID is sent
      // in requests.
      secret: config.clientSecret ?? '',
      codeVerifier: codeVerifier,
      httpClient: _httpClient,
    );
    return _authCodeGrant!
        .getAuthorizationUrl(
          redirectUri ?? config.redirectUri,
          scopes: config.scopes,
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

  @protected
  Future<oauth2.Credentials> handleExchange(
      Map<String, String> parameters) async {
    final client =
        await _authCodeGrant!.handleAuthorizationResponse(parameters);
    return client.credentials;
  }

  /// Performs the second part of the authorization code flow, exhanging the
  /// parameters retrieved via the WebView with the OAuth server for an access
  /// and refresh token.
  @override
  Future<Client> exchange(Map<String, String> parameters) async {
    await init();

    if (_authCodeGrant == null) {
      throw StateError('Must call authorize first.');
    }

    if (parameters.containsKey('error')) {
      final error = parameters['error']!;
      final errorDesc = parameters['error_description'];
      final errorUri = parameters['error_uri'];
      addState(_buildError(errorDesc, code: error, uri: errorUri));
      throw AuthException(error);
    }

    addState(const AuthLoading());

    try {
      final oauthCredentials = await handleExchange(parameters);
      final credentials = Credentials.fromOAuthCredentials(
        oauthCredentials,
        config: config,
        storageRepo: _storageRepo,
        httpClient: _httpClient,
      );

      await Future.wait([
        _storageRepo.setString(keyAccessToken, credentials.accessToken),
        if (credentials.expirationSecondsSinceEpoch != null)
          _storageRepo.setString(
            keyAccessTokenExp,
            credentials.expirationSecondsSinceEpoch!.toString(),
          ),
        if (credentials.refreshToken != null)
          _storageRepo.setString(keyRefreshToken, credentials.refreshToken!),
        if (credentials.idToken != null)
          _storageRepo.setString(keyIdToken, credentials.idToken!),
      ]);

      final newClient = Client(
        credentials: credentials,
        clientId: config.clientId,
        sslRepository: _sslRepository,
        authorizer: this,
        httpClient: _baseClient,
      );

      User? user;
      try {
        user = await UserRepo(config, newClient, _storageRepo).getUserInfo();
      } on Exception catch (e) {
        FTAuth.error('Error downloading user: $e');
      }

      addState(AuthSignedIn(newClient, user));

      await Future.wait([
        _storageRepo.delete(keyState),
        _storageRepo.delete(keyCodeVerifier),
      ]);

      return newClient;
    } catch (e) {
      addState(AuthFailure('${e.runtimeType}', e.toString()));
      rethrow;
    }
  }

  Future<void> _clearStorageForLogout() async {
    // Delete all auth keys, but leave other keys present.
    // Calling _storageRepo.clear() is probably not what
    // we want to do.
    await Future.wait(
      [
        keyAccessToken,
        keyAccessTokenExp,
        keyRefreshToken,
        keyIdToken,
        keyState,
        keyCodeVerifier,
        keyUserInfo,
      ].map(_storageRepo.delete),
    );
  }

  @override
  Future<void> logout() async {
    await _clearStorageForLogout();
    addState(const AuthSignedOut());
  }

  @override
  bool isPinning(String host) {
    return _sslRepository.isPinning(host);
  }

  @override
  void pinCert(Certificate certificate) {
    _sslRepository.pinCert(certificate);
  }
}
