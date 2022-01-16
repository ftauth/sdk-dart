import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:ftauth/ftauth.dart';
import 'package:ftauth/src/http/inline_client.dart';
import 'package:http/http.dart' as http;

typedef SetupHandler = FutureOr<void> Function(FTAuth);

abstract class FTAuthInterface
    implements AuthorizerInterface, SSLPinningInterface {
  /// Whether or not a user is currently logged in.
  bool get isLoggedIn;

  /// Retrieves the currently logged in user.
  User? get currentUser;
}

/// The main utility class. It is generally not necessary to work with this
/// class directly.
class FTAuth extends http.BaseClient implements FTAuthInterface {
  /// Override this value to set the logger for the SSO module.
  static LoggerInterface logger = const StdoutLogger();

  static void debug(String log) => logger.debug(log);
  static void info(String log) => logger.info(log);
  static void warn(String log) => logger.warn(log);
  static void error(String log) => logger.error(log);

  final http.Client _baseClient;
  final Duration _timeout;
  final Config config;
  late final AuthorizerInterface authorizer;

  FTAuth(
    this.config, {
    StorageRepo? storageRepo,
    AuthorizerInterface? authorizer,
    http.Client? baseClient,
    Duration? timeout,
    Uint8List? encryptionKey,
    SetupHandler? setup,
    bool? clearOnFreshInstall,
    ConfigChangeStrategy configChangeStrategy = ConfigChangeStrategy.ignore,
  })  : _baseClient = baseClient ?? http.Client(),
        _timeout = timeout ?? const Duration(seconds: 60) {
    switch (config.provider) {
      default:
        this.authorizer = authorizer ??
            AuthorizerImpl(
              config,
              storageRepo: storageRepo ?? StorageRepo.instance,
              baseClient: baseClient,
              clearOnFreshInstall: clearOnFreshInstall,
              configChangeStrategy: configChangeStrategy,
            );
        break;
    }

    // Perform setup tasks after init
    scheduleMicrotask(() => init().then((_) => setup?.call(this)));
  }

  /// {@template ftauth.retrieve_demo_config}
  /// Creates a temporary client configuration on the hosted FTAuth Demo
  /// server (https://demo.ftauth.io), with a single [username] and [password].
  ///
  /// Clients created with this method are not guaranteed to be always be
  /// available and should be regarded as ephemeral.
  /// {@endtemplate}
  static Future<Config> retrieveDemoConfig({
    required Uri redirectUri,
    String? name,
    ClientType type = ClientType.public,
    String username = 'test',
    String password = 'test',
    http.Client? httpClient,
  }) async {
    httpClient ??= http.Client();

    final gatewayUri = Uri.parse('https://demo.ftauth.io');
    final registerUri = gatewayUri.resolve('client/register');
    final random = Random();

    // Register a new demo client.
    final redirectUris = {'localhost', 'myapp://'}..add(redirectUri.toString());
    final resp = await httpClient.post(
      registerUri,
      body: jsonEncode({
        'name': name ?? 'demo_client_${random.nextInt(2 << 30)}',
        'type': type.toString().split('.').last,
        'redirect_uris': redirectUris.toList(),
        'scopes': ['default'],
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (resp.statusCode != 200) {
      throw ApiException.post(registerUri, resp.statusCode, resp.body);
    }
    final data = jsonDecode(resp.body) as Map;
    final clientInfo = ClientInfo.fromJson(data.cast());
    final config = Config(
      gatewayUri: gatewayUri,
      clientId: clientInfo.id,
      clientSecret: clientInfo.secret,
      clientType: clientInfo.type,
      redirectUri: redirectUri,
      scopes: clientInfo.scopes,
      grantTypes: clientInfo.grantTypes,
    );
    final client = FTAuth(config, baseClient: httpClient);

    // Create the default user.
    final signUpUri = gatewayUri.resolve('/register');
    final user = await client._basicAuthClient.post(
      signUpUri,
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (user.statusCode != 200) {
      throw ApiException.post(signUpUri, user.statusCode, user.body);
    }

    return config;
  }

  /// A client with `Basic` authorization, used for identifying to the server
  /// with the client ID and secret.
  http.Client get _basicAuthClient => InlineClient(send: (request) {
        if (!request.headers.containsKey('Authorization')) {
          request.headers['Authorization'] =
              createBasicAuthorization(config.clientId, config.clientSecret);
        }
        return _baseClient.send(request);
      });

  @override
  Future<void> init() => authorizer.init();

  @override
  Stream<AuthState> get authStates => authorizer.authStates;

  @override
  AuthState get currentState => authorizer.currentState;

  @override
  Future<void> refreshAuthState() => authorizer.refreshAuthState();

  @override
  bool get isLoggedIn => currentState is AuthSignedIn;

  @override
  User? get currentUser {
    final state = currentState;
    if (state is AuthSignedIn) {
      return state.user;
    }
    return null;
  }

  @override
  Future<void> logout({bool deinit = false}) {
    FTAuth.info('Logging out...');
    return authorizer.logout(deinit: deinit);
  }

  @override
  Future<String> authorize({
    String? language,
    String? countryCode,
  }) =>
      authorizer.authorize(language: language, countryCode: countryCode);

  @override
  Future<void> launchUrl(String url) {
    return authorizer.launchUrl(url);
  }

  @override
  Future<Client> exchange(Map<String, String> parameters) =>
      authorizer.exchange(parameters);

  @override
  Future<void> login({String? language, String? countryCode}) =>
      authorizer.login(
        language: language,
        countryCode: countryCode,
      );

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    await authorizer.refreshAuthState();
    final state = currentState;
    if (state is AuthSignedIn) {
      return state.client.send(request).timeout(_timeout);
    }
    return _basicAuthClient.send(request).timeout(_timeout);
  }

  @override
  bool isPinning(String host) {
    return authorizer.isPinning(host);
  }

  @override
  void pinCert(Certificate certificate) {
    authorizer.pinCert(certificate);
  }
}
