import 'dart:async';

import 'package:ftauth/src/credentials.dart';

import 'model/state/auth_state.dart';

class Client {
  final StreamController<AuthState> _authStateController =
      StreamController<AuthState>();

  /// The authorized credentials for this client, including the
  /// access and refresh tokens and relevant metadata.
  final Credentials credentials;

  Client({
    required this.credentials,
  });

  Stream<AuthState> get authState => _authStateController.stream;
}
