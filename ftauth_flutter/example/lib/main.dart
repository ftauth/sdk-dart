import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ftauth_flutter/ftauth_flutter.dart';

Future<void> main() async {
  final config = FTAuthConfig(
    gatewayUrl: 'https://7602aa8d005e.ngrok.io',
    clientId: '3cf9a7ac-9198-469e-92a7-cc2f15d8b87d',
    clientType: ClientType.public,
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

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: ElevatedButton(
            child: Text('Login'),
            onPressed: () {
              FTAuth.of(context).login();
            },
          ),
        ),
      ),
    );
  }
}
