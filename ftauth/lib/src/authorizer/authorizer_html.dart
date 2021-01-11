import 'dart:html';

import 'package:ftauth/ftauth.dart';

import 'authorizer.dart';

class AuthorizerImpl extends Authorizer {
  AuthorizerImpl(Config config) : super(config);

  @override
  Future<void> launchUrl(String url) async {
    window.location.replace(url);
  }
}
