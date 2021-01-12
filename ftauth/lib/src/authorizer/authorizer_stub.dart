import 'package:ftauth/ftauth.dart';

import 'authorizer.dart';

class AuthorizerImpl extends Authorizer {
  AuthorizerImpl(FTAuthConfig config) : super(config);

  @override
  Future<void> authorize() {
    throw UnimplementedError();
  }

  @override
  Future<void> launchUrl(String url) {
    throw UnimplementedError();
  }
}
