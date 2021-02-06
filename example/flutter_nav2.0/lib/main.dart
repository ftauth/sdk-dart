import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ftauth_flutter/ftauth_flutter.dart';

import 'routes.dart';

Future<void> main() async {
  final config = FTAuthConfig(
    gatewayUrl: 'https://bd72f19486b4.ngrok.io',
    clientId: '1deddb6d-7957-40a1-a323-77725cecfa18',
    redirectUri: kIsWeb ? 'http://localhost:8080/#/auth' : 'myapp://auth',
  );

  await FTAuth.initFlutter(config: config);

  config.authStates.listen((state) {
    print('State change: $state');
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

    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerDelegate: AppRouterDelegate(config),
      routeInformationParser: AppRouteInformationParser(),
    );
  }
}
