import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ftauth_flutter/ftauth_flutter.dart';

Future<void> main() async {
  final config = FTAuthConfig(
    gatewayUrl: 'https://ea180f993c95.ngrok.io',
    clientId: '3cf9a7ac-9198-469e-92a7-cc2f15d8b87d',
    clientType: ClientType.public,
    redirectUri: kIsWeb ? 'http://localhost:8080/#/auth' : 'myapp://auth',
  );

  await FTAuth.initFlutter(config: config);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FTAuth Example'),
        ),
        body: Center(
          child: ElevatedButton(
            child: Text('Login'),
            onPressed: () => FTAuth.login(),
          ),
        ),
      ),
    );
  }
}
