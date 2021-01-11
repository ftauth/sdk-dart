import 'package:ftauth/ftauth.dart';
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
