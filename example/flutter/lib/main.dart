import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ftauth_flutter/ftauth_flutter.dart' as ftauth;

import 'routes.dart';

// void -> Future<void>
Future<void> main() async {
  // {{ .Config }}
  final config = ftauth.Config(
    gatewayUrl: 'http://localhost:8000',
    clientId: 'ee1de5ad-c4a8-415c-8ff6-769ca0fd3bf1',
    redirectUri: kIsWeb ? 'http://localhost:8080/#/auth' : 'myapp://auth',
  );

  // {{ .Init }}
  await ftauth.initFlutter(config: config);

  runApp(
    ftauth.Auth(
      config: config,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final config = ftauth.Auth.of(context);

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
