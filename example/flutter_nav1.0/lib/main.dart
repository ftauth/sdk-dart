import 'package:example_flutter/screens/auth_screen.dart';
import 'package:example_flutter/screens/home_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ftauth_flutter/ftauth_flutter.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  final config = FTAuthConfig(
    gatewayUrl: 'https://519dc21e0d47.ngrok.io',
    clientId: 'ee1de5ad-c4a8-415c-8ff6-769ca0fd3bf1',
    redirectUri: kIsWeb ? 'http://localhost:8080/#/auth' : 'myapp://auth',
  );

  await FTAuth.initFlutter(config: config);

  // Listen to state changes and ensure that the AuthScreen is presented
  // when the user is logged out, either via pressing the Logout button or
  // because their session has expired.
  config.authStates.listen((state) {
    // Replace screen with AuthScreen if not already showing.
    if (state is AuthSignedOut &&
        _rootNavigatorKey.currentWidget is! AuthScreen) {
      // Don't interfere with current frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _rootNavigatorKey.currentState.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext _) => AuthScreen(),
          ),
          (route) => false,
        );
      });
    }
  });

  runApp(
    FTAuth(
      config: config,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final config = FTAuth.of(context);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/auth',
      debugShowCheckedModeBanner: false,
      navigatorKey: _rootNavigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name.startsWith('/auth')) {
          final parts = settings.name.split('?');

          // Callback will be in the form of /auth?state=somestate&code=somecode
          final hasQueryParameters = parts.length > 1;
          if (hasQueryParameters) {
            final params = Uri.splitQueryString(parts[1]);
            config.exchangeAuthorizationCode(params);
          }
          return MaterialPageRoute(
            builder: (BuildContext _) => AuthScreen(),
          );
        }

        return MaterialPageRoute(
          builder: (BuildContext _) => HomeScreen(),
        );
      },
    );
  }
}
