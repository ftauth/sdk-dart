import 'package:flutter/material.dart';
import 'package:ftauth_example/keys.dart';
import 'package:ftauth_flutter/ftauth_flutter.dart';

class AuthStateIndicator extends StatelessWidget {
  static const _authStateKey = const Key(keyAuthStateText);

  const AuthStateIndicator({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final largeTextStyle = Theme.of(context).textTheme.headline5;

    return StreamBuilder<AuthState>(
      stream: FTAuth.of(context).authStates,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        switch (snapshot.data.runtimeType) {
          case AuthSignedOut:
            return Text(
              'Logged Out',
              key: _authStateKey,
              style: largeTextStyle,
            );
          case AuthSignedIn:
            final state = snapshot.data as AuthSignedIn;
            return Column(
              children: [
                Text(
                  'Logged In',
                  key: _authStateKey,
                  style: largeTextStyle,
                ),
                Text('Username: ${state.user?.id}'),
              ],
            );
          case AuthFailure:
            final state = snapshot.data as AuthFailure;
            return Column(
              children: [
                Text(
                  'Error',
                  key: _authStateKey,
                  style: largeTextStyle,
                ),
                Text(state.toString()),
              ],
            );
          case AuthLoading:
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
