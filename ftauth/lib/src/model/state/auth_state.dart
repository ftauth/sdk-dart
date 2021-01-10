import 'package:equatable/equatable.dart';
import 'package:ftauth/src/model/user/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSignedIn extends AuthState {
  final User user;

  AuthSignedIn(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthSignedOut extends AuthState {
  const AuthSignedOut();
}
