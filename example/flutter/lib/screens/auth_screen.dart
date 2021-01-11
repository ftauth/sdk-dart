import 'package:example_flutter/routes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ftauth_flutter/ftauth_flutter.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatelessWidget {
  final AuthRouteInfo routeInfo;

  AuthScreen([this.routeInfo = const AuthRouteInfo.empty()]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: StreamBuilder(
          stream: FTAuth.instance.authStates,
          initialData: const AuthLoading(),
          builder: (context, snapshot) {
            final state = snapshot.data;
            switch (state.runtimeType) {
              case AuthLoading:
                return CircularProgressIndicator();
              case AuthSignedOut:
                return RaisedButton(
                  child: Text('Login'),
                  onPressed: () async {
                    final config = Provider.of<Config>(context, listen: false);
                    if (kIsWeb) {
                      await config.authorize();
                    } else {
                      await config.login();
                    }
                  },
                );
              default:
                return Container();
            }
          },
        ),
      ),
    );
  }
}
