import 'package:equatable/equatable.dart';
import 'package:ftauth/ftauth.dart';

/// The state of authorization for the app.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];

  @override
  String toString();
}

/// The user's state is being retrieved or refreshed.
class AuthLoading extends AuthState {
  const AuthLoading();

  @override
  String toString() => 'AuthLoading{}';
}

/// The user is logged in with the requested privileges.
class AuthSignedIn extends AuthState {
  final Client client;
  final User? user;

  const AuthSignedIn(this.client, this.user);

  @override
  String toString() => 'AuthSignedIn{}';

  @override
  List<Object?> get props => [client, user];
}

/// The user is logged out or their access has expired.
class AuthSignedOut extends AuthState {
  const AuthSignedOut();

  @override
  String toString() => 'AuthSignedOut{}';
}

/// An error occurred during authorization.
class AuthFailure extends AuthState {
  final String code;
  final String message;

  const AuthFailure(this.code, [this.message = 'An unknown error occurred.']);

  factory AuthFailure.fromException(Object e) =>
      AuthFailure('${e.runtimeType}', e.toString());

  @override
  String toString() {
    return 'AuthFailure{code=$code, message=$message}';
  }
}
