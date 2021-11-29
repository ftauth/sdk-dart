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
      'e2b5eb85-4010-4bd9-ab35-33a766adc3e3',
    );
  }

  factory AppConfig.prod() {
    return AppConfig(
      Environment.prod,
      'https://demo.ftauth.io',
      'b4f919f3-8599-4439-8dc6-18cd8ccf2859',
    );
  }
}
