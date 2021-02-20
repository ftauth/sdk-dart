import 'dart:async';

import 'package:ftauth/ftauth.dart';
import 'package:ftauth/src/demo/http.dart';
import 'package:ftauth/src/model/user/user.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'data.dart';

class _DemoCreds implements Credentials {
  @override
  String get accessToken => throw UnimplementedError();

  @override
  bool get canRefresh => throw UnimplementedError();

  @override
  DateTime get expiration => throw UnimplementedError();

  @override
  String? get idToken => throw UnimplementedError();

  @override
  bool get isExpired => throw UnimplementedError();

  @override
  String get refreshToken => throw UnimplementedError();

  @override
  List<String> get scopes => throw UnimplementedError();

  @override
  String toJson() {
    throw UnimplementedError();
  }

  @override
  Uri get tokenEndpoint => throw UnimplementedError();

  @override
  User get user => throw UnimplementedError();

  @override
  Future<Credentials> refresh(
      {String? identifier,
      String? secret,
      Iterable<String>? newScopes,
      bool basicAuth = true,
      http.Client? httpClient}) {
    throw UnimplementedError();
  }
}

class _DemoClient extends Client {
  _DemoClient() : super(clientId: Uuid().v4(), credentials: _DemoCreds());
  final _client = DemoHttpClient();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request);
  }
}

class DemoAuthorizer implements Authorizer {
  AuthState? _latestAuthState;
  Future<AuthState>? _initStateFuture;
  final _authStateController = StreamController<AuthState>.broadcast();

  @override
  http.Client get httpClient => http.Client();

  @override
  Stream<AuthState> get authStates async* {
    if (_latestAuthState == null) {
      _initStateFuture ??= initialize();
      _latestAuthState = await _initStateFuture!;
    }
    yield _latestAuthState!;
    yield* _authStateController.stream;
  }

  void _addAuthState(AuthState next) {
    _latestAuthState = next;
    _authStateController.add(next);
  }

  @override
  Future<Client> loginWithCredentials() async {
    await (_initStateFuture ??= initialize());

    _addAuthState(const AuthLoading());
    await Future<void>.delayed(const Duration(seconds: 2));
    final client = _DemoClient();
    _addAuthState(AuthSignedIn(client, demoUser));
    return client;
  }

  @override
  Future<Client> exchange(Map<String, String> parameters) async {
    await (_initStateFuture ??= initialize());

    _addAuthState(const AuthLoading());
    await Future<void>.delayed(const Duration(seconds: 2));
    final client = _DemoClient();
    _addAuthState(AuthSignedIn(client, demoUser));
    return client;
  }

  @override
  Future<String> getAuthorizationUrl() {
    throw UnimplementedError();
  }

  Future<AuthState> initialize() async {
    if (_initStateFuture != null) {
      return _initStateFuture!;
    }
    await Future<void>.delayed(const Duration(seconds: 2));
    return AuthSignedOut();
  }

  @override
  Future<void> logout() async {
    _addAuthState(const AuthSignedOut());
  }

  @override
  Future<Client> loginWithUsernameAndPassword(
      String username, String password) {
    return loginWithCredentials();
  }

  @override
  Future<String> authorize() {
    throw UnimplementedError();
  }
}

class DemoConfig extends FTAuthConfig {
  DemoConfig()
      : super(
          clientId: Uuid().v4(),
          gatewayUrl: 'http://localhost:8080',
          redirectUri: 'http://localhost:8080',
        );
}
