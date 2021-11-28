import 'dart:html';

enum Environment { dev, prod }

class AppConfig {
  final Environment env;
  final String host;

  AppConfig(this.env, this.host);

  factory AppConfig.dev() {
    return AppConfig(Environment.dev, 'https://demo.ftauth.io');
  }

  factory AppConfig.prod() {
    return AppConfig(Environment.prod, 'http://${window.location.host}');
  }
}
