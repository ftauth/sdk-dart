import 'package:flutter/foundation.dart';
import 'package:ftauth/ftauth.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

class FlutterAuthorizer extends Authorizer {
  FlutterAuthorizer(Config config) : super(config);

  @override
  Future<void> launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url, webOnlyWindowName: '_self');
    }
  }
}

extension ConfigX on Config {
  Future<Client> login() async {
    if (kIsWeb) {
      throw AssertionError(
          'login should only be called for Flutter mobile clients. '
          'All other clients (web/desktop) should use authorize.');
    }
    await FTAuth.instance.authorizer.authorize();

    final redirect = await getLinksStream().firstWhere(
      (url) => url.startsWith(redirectUri.toString()),
    );

    final queryParams = Uri.parse(redirect).queryParameters;

    return FTAuth.instance.authorizer
        .exchangeAuthorizationCode(queryParams, scopes);
  }
}
