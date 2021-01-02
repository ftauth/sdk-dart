import 'package:equatable/equatable.dart';
import 'package:ftauth/src/model/user/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthLoggedIn extends AuthState {
  final User user;

  AuthLoggedIn(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthLoggedOut extends AuthState {
  const AuthLoggedOut();
}
