import 'package:ftauth/ftauth.dart';

import 'authorizer.dart';

class AuthorizerImpl extends Authorizer {
  @override
  Future<Client> authorize(Config config) async {
    if (config.clientType == ClientType.public) {
      throw UnsupportedError(
          'Public clients cannot be used in server-side applications.');
    }

    assert(
      config.clientSecret != null,
      'Client secret must be provided for confidential clients.',
    );

    // Perform client credentials grant

    return Client(credentials: Credentials());
  }

  @override
  Future<void> launchUrl(String url) {
    throw UnsupportedError('Server-side applications cannot launch URLs');
  }
}
