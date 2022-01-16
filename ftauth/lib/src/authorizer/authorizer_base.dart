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
abstract class Authorizer implements AuthorizerInterface, SSLPinningInterface {
  /// The configuration for this authorizer. This may be updated throughout the
  /// OAuth flow as new information is available.
  final Config config;

  /// The base client to use for internal HTTP calls.
  late final http.Client _baseClient;

  /// Stores client-sensitive information related to the OAuth flow. Must be
  /// persistent, so that state can be recovered on startup.
  @protected
  final StorageRepo storageRepo;

  /// Encryption key used for [storageRepo].
  final Uint8List? _encryptionKey;

  /// Whether to clear previous Keychain items on a fresh install.
  final bool clearOnFreshInstall;

  /// The strategy to use when FTAuth is initialized with a new, conflicting
  /// configuration (client ID).
  final ConfigChangeStrategy configChangeStrategy;

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
  @override
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
  @protected
  oauth2.AuthorizationCodeGrant? authCodeGrant;

  Authorizer(
    this.config, {
    required this.storageRepo,
    SSLRepo? sslRepository,
    http.Client? baseClient,
    Duration? timeout,
    Uint8List? encryptionKey,
    bool? clearOnFreshInstall,
    required this.configChangeStrategy,
  })  : _sslRepository = sslRepository ?? SSLRepoImpl(storageRepo),
        _encryptionKey = encryptionKey,
        clearOnFreshInstall = clearOnFreshInstall ?? true {
    _baseClient = SSLPinningClient(
      _sslRepository,
      baseClient: baseClient,
      timeout: timeout,
    );
  }

  /// Handles internal HTTP requests.
  @protected
  http.Client get httpClient {
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

  /// Initializes the SDK.
  ///
  /// It is safe to call this method more than once.
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

    await storageRepo.init(encryptionKey: _encryptionKey);

    // Checks if this is the first time starting the app from a fresh install.
    // If it is, clear any old Keychain information which may be left behind
    // from previous installs.
    final isFreshInstall =
        await storageRepo.getEphemeralString(keyFreshInstall) == null;
    if (isFreshInstall && clearOnFreshInstall) {
      FTAuth.debug('Clearing old Keychain items...');
      await storageRepo.clear();
      await storageRepo.setEphemeralString(keyFreshInstall, 'flag');
    }

    // Checks if re-configuring with a new configuration. In this case, we
    // should also clear the storage.
    final currentConfigStr = await storageRepo.getString(keyConfig);
    if (currentConfigStr != null) {
      final currentConfig = Config.fromJson(jsonDecode(currentConfigStr));
      if (config.clientId != currentConfig.clientId) {
        switch (configChangeStrategy) {
          case ConfigChangeStrategy.clear:
            FTAuth.debug('New client ID. Clearing old Keychain items...');
            await storageRepo.clear();
            break;
          case ConfigChangeStrategy.ignore:
            FTAuth.debug('New client ID. Ignoring...');
            FTAuth.info(
                'To configure a new client ID, change your `configChangeStrategy` '
                'to `clear` or call .logout(deinit: true).');
            break;
        }
      }
    }

    // Initialize the SSL repository
    await _sslRepository.init();

    // Store locally the current config
    await storageRepo.setString(keyConfig, jsonEncode(config));

    try {
      final stateFromStorage = await _reloadFromStorage();
      if (stateFromStorage != null) {
        return stateFromStorage;
      }

      final state = await storageRepo.getString(keyState);
      final codeVerifier = await storageRepo.getString(keyCodeVerifier);

      if (state != null && codeVerifier != null) {
        return onFoundState(state: state, codeVerifier: codeVerifier);
      }

      return const AuthSignedOut();
    } catch (e) {
      return AuthFailure('${e.runtimeType}', e.toString());
    }
  }

  /// Called when FTAuth initializes and a previous [state] and [codeVerifier]
  /// were found in storage. This generally means we are returning from a login
  /// or have stale info which should be cleared.
  @protected
  Future<AuthState> onFoundState({
    required String state,
    required String codeVerifier,
  }) async {
    FTAuth.debug('State and code verifier found. Logging out.');
    await _clearStorageForLogout();
    FTAuth.info('User is logged out.');
    return const AuthSignedOut();
  }

  /// Reloads the current AuthState from storage, if present.
  Future<AuthState?> _reloadFromStorage() async {
    FTAuth.debug('Reloading tokens from storage...');
    final accessTokenEnc = await storageRepo.getString(keyAccessToken);
    final refreshTokenEnc = await storageRepo.getString(keyRefreshToken);
    final idTokenEnc = await storageRepo.getString(keyIdToken);

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
      storageRepo: storageRepo,
      httpClient: httpClient,
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
      user = await UserRepo(config, client, storageRepo).getUserInfo();
    } on Exception catch (e) {
      FTAuth.error('Error downloading user: $e');
    }

    FTAuth.info('User is logged in.');

    return AuthSignedIn(client, user);
  }

  @override
  Future<void> refreshAuthState() async {
    await init();
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
  @protected
  @visibleForTesting
  @nonVirtual
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

    final state = generateState();
    final codeVerifier = createCodeVerifier();

    await Future.wait([
      storageRepo.setString(keyState, state),
      storageRepo.setString(keyCodeVerifier, codeVerifier),
    ]);

    authCodeGrant = createGrant(
      config,
      codeVerifier: codeVerifier,
      httpClient: httpClient,
    );
    return authCodeGrant!
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
  Future<AuthSignedIn> handleExchange(Map<String, String> parameters) async {
    if (authCodeGrant == null) {
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

    final client = await authCodeGrant!.handleAuthorizationResponse(parameters);
    final oauthCredentials = client.credentials;
    final credentials = Credentials.fromOAuthCredentials(
      oauthCredentials,
      config: config,
      storageRepo: storageRepo,
      httpClient: httpClient,
    );

    await Future.wait([
      storageRepo.setString(keyAccessToken, credentials.accessToken),
      if (credentials.expirationSecondsSinceEpoch != null)
        storageRepo.setString(
          keyAccessTokenExp,
          credentials.expirationSecondsSinceEpoch!.toString(),
        ),
      if (credentials.refreshToken != null)
        storageRepo.setString(keyRefreshToken, credentials.refreshToken!),
      if (credentials.idToken != null)
        storageRepo.setString(keyIdToken, credentials.idToken!),
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
      user = await UserRepo(config, newClient, storageRepo).getUserInfo();
    } on Exception catch (e) {
      FTAuth.error('Error downloading user: $e');
    }

    await Future.wait([
      storageRepo.delete(keyState),
      storageRepo.delete(keyCodeVerifier),
    ]);

    return AuthSignedIn(newClient, user);
  }

  @override
  Future<Client> exchange(Map<String, String> parameters) async {
    try {
      final state = await handleExchange(parameters);
      addState(state);
      return state.client;
    } on Exception catch (e) {
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
      ].map(storageRepo.delete),
    );
  }

  @override
  Future<void> logout({bool deinit = false}) async {
    if (deinit) {
      await storageRepo.clear();
    } else {
      await _clearStorageForLogout();
    }
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
