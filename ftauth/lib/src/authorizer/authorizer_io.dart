import 'package:ftauth/ftauth.dart';

import 'authorizer.dart';

class AuthorizerImpl extends Authorizer {
  AuthorizerImpl(Config config) : super(config);

  @override
  Future<Client> authorize() async {
    if (config.clientType == ClientType.public) {
      throw UnsupportedError(
          'Public clients cannot be used in server-side applications.');
    }

    assert(
      config.clientSecret != null,
      'Client secret must be provided for confidential clients.',
    );

    // ignore: invalid_use_of_visible_for_testing_member
    return authorizeConfidentialClient();
  }

  @override
  Future<void> launchUrl(String url) {
    throw UnsupportedError('Server-side applications cannot launch URLs');
  }
}
