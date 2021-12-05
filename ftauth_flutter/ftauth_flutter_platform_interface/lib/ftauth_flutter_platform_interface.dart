library ftauth_flutter_platform_interface;

import 'dart:typed_data';

import 'package:ftauth/ftauth.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'src/method_channel_ftauth.dart';

export 'src/config.dart';
export 'src/platform_exception_codes.dart';

/// The interface that implementations of FTAuth must implement.
///
/// Platform implementations should extend this class rather than implement it as `FTAuth`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [FTAuthPlatformInterface] methods.
abstract class FTAuthPlatformInterface extends PlatformInterface
    implements AuthorizerInterface {
  FTAuthPlatformInterface() : super(token: _token);

  static final Object _token = Object();

  static FTAuthPlatformInterface _instance = MethodChannelFTAuth();

  static FTAuthPlatformInterface get instance => _instance;

  static set instance(FTAuthPlatformInterface instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Authorizer? _authorizer;
  Authorizer get authorizer {
    if (_authorizer == null) {
      throw StateError('Must call createAuthorizer first');
    }
    return _authorizer!;
  }

  set authorizer(Authorizer authorizer) {
    if (_authorizer != null) {
      throw StateError('Cannot register multiple authorizers');
    }
    _authorizer = authorizer;
  }

  void createAuthorizer(
    Config config, {
    required StorageRepo storageRepo,
    SSLRepo? sslRepository,
    http.Client? baseClient,
    Duration? timeout,
    Uint8List? encryptionKey,
    bool? clearOnFreshInstall,
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<AuthState> get authStates => authorizer.authStates;

  @override
  Future<String> authorize({
    String? language,
    String? countryCode,
  }) =>
      authorizer.authorize(
        language: language,
        countryCode: countryCode,
      );

  @override
  AuthState get currentState => authorizer.currentState;

  @override
  Future<Client> exchange(Map<String, String> parameters) =>
      authorizer.exchange(parameters);

  @override
  Future<void> init() => authorizer.init();

  @override
  bool isPinning(String host) => authorizer.isPinning(host);

  @override
  Future<void> launchUrl(String url) => authorizer.launchUrl(url);

  @override
  Future<void> login({
    String? language,
    String? countryCode,
  }) =>
      authorizer.login(
        language: language,
        countryCode: countryCode,
      );

  @override
  Future<void> logout() => authorizer.logout();

  @override
  void pinCert(Certificate certificate) => authorizer.pinCert(certificate);

  @override
  Future<void> refreshAuthState() => authorizer.refreshAuthState();
}
