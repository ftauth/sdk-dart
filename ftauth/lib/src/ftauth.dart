import 'dart:async';
import 'dart:typed_data';

import 'package:ftauth/ftauth.dart';
import 'package:http/http.dart' as http;

typedef SetupHandler = FutureOr<void> Function(FTAuth);

abstract class FTAuthInterface
    implements AuthorizerInterface, SSLPinningInterface {
  Future<void> logout();
  Stream<AuthState> get authStates;
  bool get isLoggedIn;
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
  late final Authorizer authorizer;

  FTAuth(
    this.config, {
    StorageRepo? storageRepo,
    Authorizer? authorizer,
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
            Authorizer(
              config,
              storageRepo: storageRepo ?? StorageRepo.instance,
              baseClient: baseClient,
              clearOnFreshInstall: clearOnFreshInstall,
            );
        break;
    }

    // Perform setup tasks after init
    init().then((_) => scheduleMicrotask(() => setup?.call(this)));
  }

  /// Initializes the SDK. **Must** be called before performing any activities
  /// like SSL pinning.
  @override
  Future<void> init() => authorizer.init();

  /// Returns the stream of authorization states.
  ///
  /// Possible [AuthState] values include:
  /// * [AuthLoading]: Information is refreshing or being retrieved.
  /// * [AuthSignedIn]: User is logged in with valid credentials.
  /// * [AuthSignedOut]: User is logged out or has expired credentials.
  /// * [AuthFailure]: An error has occurred during authentication or during an HTTP request.
  @override
  Stream<AuthState> get authStates => authorizer.authStates;

  /// The current authorization state.
  @override
  AuthState get currentState => authorizer.currentState;

  /// Whether or not a user is currently logged in.
  @override
  bool get isLoggedIn => currentState is AuthSignedIn;

  /// Retrieves the currently logged in user.
  @override
  User? get currentUser {
    final state = currentState;
    if (state is AuthSignedIn) {
      return state.user;
    }
    return null;
  }

  /// Logs out the current user.
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
  Future<Client> exchange(Map<String, String> parameters) =>
      authorizer.exchange(parameters);

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
