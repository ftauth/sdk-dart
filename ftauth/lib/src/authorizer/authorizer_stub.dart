import 'package:ftauth/ftauth.dart';

import 'authorizer.dart';

class AuthorizerImpl extends Authorizer {
  AuthorizerImpl(Config config) : super(config);

  @override
  Future<Client> authorize() {
    throw UnimplementedError();
  }

  @override
  Future<void> launchUrl(String url) {
    throw UnimplementedError();
  }
}
