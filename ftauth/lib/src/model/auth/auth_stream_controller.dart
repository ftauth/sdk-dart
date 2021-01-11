import 'dart:async';

import 'package:ftauth/ftauth.dart';

class AuthStreamController {
  AuthState? _lastState;

  final _authStateController = StreamController<AuthState>.broadcast();
}
