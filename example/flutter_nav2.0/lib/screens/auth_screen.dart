import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ftauth_flutter/ftauth_flutter.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: StreamBuilder(
          stream: FTAuth.of(context).authStates,
          initialData: const AuthLoading(),
          builder: (context, snapshot) {
            final state = snapshot.data;
            switch (state.runtimeType) {
              case AuthLoading:
                return const CircularProgressIndicator();
              case AuthSignedOut:
                return RaisedButton(
                  child: const Text('Login'),
                  onPressed: () async {
                    final ftauth = FTAuth.of(context);

                    if (kIsWeb) {
                      await ftauth.authorize();
                    } else {
                      await ftauth.login();
                    }
                  },
                );
              case AuthFailure:
                final message = (state as AuthFailure).toString();
                return Text(message);
              default:
                return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}
