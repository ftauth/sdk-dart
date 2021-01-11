import 'package:equatable/equatable.dart';
import 'package:ftauth/ftauth.dart';
import 'package:ftauth/src/model/user/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// The user's state is being retrieved or refreshed.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// The user is logged in with the requested privileges.
class AuthSignedIn extends AuthState {
  final Client client;
  final User user;

  const AuthSignedIn(this.client, this.user);

  @override
  List<Object?> get props => [client, user];
}

/// The user is logged out or their access has expired.
class AuthSignedOut extends AuthState {
  const AuthSignedOut();
}

/// An error occurred during authorization.
class AuthFailure extends AuthState {
  final String code;
  final String message;

  const AuthFailure(this.code, [this.message = 'An unknown error occurred.']);

  @override
  String toString() {
    return 'AuthFailure ($code): $message';
  }
}
