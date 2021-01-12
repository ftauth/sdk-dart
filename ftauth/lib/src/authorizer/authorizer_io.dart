import 'package:ftauth/ftauth.dart';

import 'authorizer.dart';

class AuthorizerImpl extends Authorizer {
  AuthorizerImpl(FTAuthConfig config) : super(config);

  @override
  Future<void> launchUrl(String url) {
    throw UnsupportedError('Server-side applications cannot launch URLs');
  }
}
