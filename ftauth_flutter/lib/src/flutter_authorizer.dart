import 'package:ftauth/ftauth.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

class FlutterAuthorizer extends Authorizer {
  @override
  Future<Client> authorize(Config config) async {
    if (config.clientType == ClientType.confidential) {
      throw unsupported(config.clientType);
    }

    final authorizationUrl = await getAuthorizationUrl();

    await launchUrl(authorizationUrl);

    final redirect = await getLinksStream()
        .firstWhere((url) => url.startsWith(config.redirectUri));

    final queryParams = Uri.parse(redirect).queryParameters;

    final credentials = await exchangeAuthorizationCode(queryParams);

    return Client(credentials: credentials);
  }

  @override
  Future<void> launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url, webOnlyWindowName: '_self');
    }
  }
}
