import 'package:ftauth/ftauth.dart';

abstract class Authorizer {
  Future<Client> authorize(Config config);
  Future<void> launchUrl(String url);
  UnsupportedError unsupported(ClientType clientType) => UnsupportedError(
      'The ${clientType.stringify} client type is not supported on this platform.');

  Future<Client> authorizeConfidentialClient(Config config) async {
    throw UnimplementedError();
  }

  Future<String> getAuthorizationUrl() async {
    throw UnimplementedError();
  }

  Future<Credentials> exchangeAuthorizationCode(
    Map<String, String> parameters,
  ) async {
    throw UnimplementedError();
  }
}
