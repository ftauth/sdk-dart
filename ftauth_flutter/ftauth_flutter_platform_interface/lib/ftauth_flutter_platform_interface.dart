library ftauth_flutter_platform_interface;

import 'package:ftauth/ftauth.dart';
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

  FTAuth? _client;
  FTAuth get client {
    if (_client == null) {
      throw StateError('Must call registerClient first.');
    }
    return _client!;
  }

  void registerClient(FTAuth client) {
    _client ??= client;
  }

  @override
  Future<String> authorize({String? language, String? countryCode}) {
    return client.authorize(
      language: language,
      countryCode: countryCode,
    );
  }

  @override
  AuthState get currentState => client.currentState;

  @override
  Future<void> refreshAuthState() => client.refreshAuthState();

  @override
  Future<Client> exchange(Map<String, String> parameters) {
    return client.exchange(parameters);
  }

  @override
  Future<void> launchUrl(String url) => client.launchUrl(url);

  @override
  Future<void> init() {
    return client.init();
  }

  @override
  Future<void> login({String? language, String? countryCode}) {
    return client.login(
      language: language,
      countryCode: countryCode,
    );
  }

  @override
  Future<void> logout() {
    return client.logout();
  }

  @override
  Stream<AuthState> get authStates => client.authStates;

  @override
  bool isPinning(String host) {
    return client.isPinning(host);
  }

  @override
  void pinCert(Certificate certificate) {
    client.pinCert(certificate);
  }
}
