import 'dart:async';
import 'dart:typed_data';

import 'package:ftauth/ftauth.dart';
import 'package:ftauth/src/demo/demo.dart';
import 'package:ftauth/src/exception.dart';
import 'package:ftauth/src/model/user/user.dart';
import 'package:ftauth/src/path_provider/path_provider.dart';
import 'package:ftauth/src/storage/storage_repo.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

const _isDemo = bool.fromEnvironment('demo', defaultValue: false);

/// The main utility class. It is generally not necessary to work with this
/// class directly.
class FTAuthImpl extends http.BaseClient implements Authorizer {
  static final instance = FTAuthImpl._();

  var _inititalized = false;
  late final FTAuthConfig _config;
  late final Authorizer _authorizer;

  FTAuthConfig get config {
    _assertInitialized();
    return _config;
  }

  Authorizer get authorizer {
    _assertInitialized();
    return _authorizer;
  }

  FTAuthImpl._();

  /// Initialize the FTAuth library.
  ///
  /// It is required to call either `init` for server and web applications or
  /// `initFlutter` for Flutter applications.
  Future<void> init(
    FTAuthConfig config, {
    Uint8List? encryptionKey,
    Authorizer? authorizer,
    StorageRepo? storageRepo,
  }) async {
    const pathProvider = PathProvider();

    // This will return null for Flutter mobile and Web, but calling `Hive.init`
    // is not required in these cases.
    final hivePath = pathProvider.getHiveDirectory();
    if (hivePath != null) {
      Hive.init(hivePath);
    }
    _config = config;
    if (_isDemo) {
      _authorizer = DemoAuthorizer();
    } else {
      _authorizer = authorizer ??
          Authorizer(
            config,
            storageRepo: storageRepo ?? StorageRepo.instance,
          );
    }

    await (storageRepo ?? StorageRepo.instance)
        .init(encryptionKey: encryptionKey);

    _inititalized = true;
  }

  void _assertInitialized() {
    if (!_inititalized) {
      throw UninitializedError();
    }
  }

  @override
  Future<String> authorize() {
    _assertInitialized();
    return _authorizer.authorize();
  }

  @override
  Future<Client> exchange(Map<String, String> parameters) {
    _assertInitialized();
    return _authorizer.exchange(parameters);
  }

  @override
  @visibleForTesting
  Future<String> getAuthorizationUrl() {
    _assertInitialized();
    // ignore: invalid_use_of_visible_for_testing_member
    return _authorizer.getAuthorizationUrl();
  }

  @override
  Future<void> logout() {
    _assertInitialized();
    return _authorizer.logout();
  }

  /// Retrieves the stream of authorization states, representing the current
  /// state of the user's authorization.
  @override
  Stream<AuthState> get authStates async* {
    _assertInitialized();
    yield* _authorizer.authStates;
  }

  /// Retrieves the current [User], or `null`, if not logged in.
  Future<User?> get currentUser async {
    _assertInitialized();
    final state = await authStates.first;
    if (state is AuthSignedIn) {
      return state.user;
    }
    return null;
  }

  /// Retrieves the current [Client] for this config, or `null` if not logged in.
  Future<Client?> get client async {
    _assertInitialized();
    final state = await authStates.first;
    if (state is AuthSignedIn) {
      return state.client;
    }
    return null;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    _assertInitialized();
    return _authorizer.httpClient.send(request);
  }

  @override
  Future<Client> loginWithCredentials() {
    _assertInitialized();
    return _authorizer.loginWithCredentials();
  }

  @override
  Future<Client> loginWithUsernameAndPassword(
      String username, String password) {
    _assertInitialized();
    return _authorizer.loginWithUsernameAndPassword(username, password);
  }

  @override
  http.Client get httpClient => _authorizer.httpClient;
}
