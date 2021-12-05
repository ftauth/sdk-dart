import 'dart:async';
import 'dart:typed_data';

import 'package:ftauth/ftauth.dart';
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
            );
        break;
    }

    // Perform setup tasks after init
    scheduleMicrotask(() => init().then((_) => setup?.call(this)));
  }

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
  Future<void> logout() {
    FTAuth.info('Logging out...');
    return authorizer.logout();
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
    final state = await authStates.first;
    if (state is AuthSignedIn) {
      return state.client.send(request).timeout(_timeout);
    }
    return _baseClient.send(request).timeout(_timeout);
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
