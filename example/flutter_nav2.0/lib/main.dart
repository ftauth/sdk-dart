import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ftauth_flutter/ftauth_flutter.dart';

import 'routes.dart';

Future<void> main() async {
  final config = FTAuthConfig(
    gatewayUrl: 'https://519dc21e0d47.ngrok.io',
    clientId: 'ee1de5ad-c4a8-415c-8ff6-769ca0fd3bf1',
    redirectUri: kIsWeb ? 'http://localhost:8080/#/auth' : 'myapp://auth',
  );

  await FTAuth.initFlutter(config: config);

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
