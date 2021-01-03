import 'package:ftauth/ftauth.dart';

import 'authorizer.dart';

class AuthorizerImpl extends Authorizer {
  @override
  Future<Client> authorize(Config config) {
    throw UnimplementedError();
  }

  @override
  Future<void> launchUrl(String url) {
    throw UnimplementedError();
  }
}
