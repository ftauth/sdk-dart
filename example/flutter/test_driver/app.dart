import 'package:flutter/widgets.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:ftauth_example/main.dart' as app;
import 'package:ftauth_flutter/ftauth_flutter.dart';
import 'webview/webview_command_extension.dart';

Future<void> main() async {
  enableFlutterDriverExtension(
    commands: [
      WebViewCommandExtension(),
    ],
  );
  WidgetsFlutterBinding.ensureInitialized();
  final config = await FTAuthConfig.fromAsset();
  final ftauth = FTAuth(
    config,
    child: const app.MyApp(),
  );
  runApp(ftauth);
}
