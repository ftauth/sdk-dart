import 'dart:html';

import 'package:ftauth/ftauth.dart';

import 'authorizer.dart';

class AuthorizerImpl extends Authorizer {
  @override
  Future<Client> authorize(Config config) async {
    if (config.clientType == ClientType.confidential) {
      throw UnsupportedError(
          'Confidential clients cannot be used in web applications.');
    }

    // Perform authorization code grant

    return Client(credentials: Credentials());
  }

  @override
  Future<void> launchUrl(String url) async {
    window.location.replace(url);
  }
}
