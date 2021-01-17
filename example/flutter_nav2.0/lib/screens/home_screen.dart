import 'package:flutter/material.dart';
import 'package:ftauth_flutter/ftauth_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen();

  Future<String> retrieveUserInfo(FTAuthConfig config) async {
    final path = config.gatewayUrl.replace(path: '/user');
    final resp = await config.get(path);
    if (resp.statusCode == 200) {
      return 'User info: ${resp.body}';
    }
    return ApiException.get(path.toString(), resp.statusCode).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: StreamBuilder<AuthState>(
            stream: FTAuth.of(context).authStates,
            initialData: const AuthLoading(),
            builder: (context, snapshot) {
              if (snapshot.data is AuthSignedIn) {
                return FutureBuilder(
                  future: retrieveUserInfo(FTAuth.of(context)),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    }
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    return Text(snapshot.data);
                  },
                );
              }

              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
