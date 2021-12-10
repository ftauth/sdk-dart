import 'package:ftauth/ftauth.dart';

enum Environment { dev, prod }

class AppConfig {
  final Environment env;
  final String host;
  final String clientId;

  AppConfig(
    this.env,
    this.host,
    this.clientId,
  );

  factory AppConfig.dev() {
    return AppConfig(
      Environment.dev,
      'http://localhost:8000',
      '3cf9a7ac-9198-469e-92a7-cc2f15d8b87d',
    );
  }

  static Future<AppConfig> prod() async {
    final config = await FTAuth.retrieveDemoConfig(
      redirectUris: ['localhost'],
    );
    return AppConfig(
      Environment.prod,
      'https://demo.ftauth.io',
      config.clientId,
    );
  }
}
