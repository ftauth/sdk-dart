import 'package:flutter/widgets.dart';
import 'package:ftauth/ftauth.dart';

/// A widget meant to wrap a top-level MaterialApp to provide an FTAuth
/// config to all decendant widgets, making login/authorize calls simpler.
///
///
/// ```
/// import 'package:ftauth_flutter/ftauth_flutter.dart' as ftauth;
///
/// Future<void> main() async {
///   final config = ftauth.Config(
///     gatewayUrl: 'http://localhost:8000',
///   );
///
///   await ftauth.initFlutter(config);
///
///   runApp(
///     ftauth.Auth(
///       config: config,
///       child: MyApp(),
///     ),
///   );
/// }
/// ```
class Auth extends InheritedWidget {
  final Config config;

  Auth({
    @required this.config,
    @required Widget child,
  }) : super(child: child);

  /// Returns the FTAuth config provided to the Auth widget on creation.
  ///
  /// Make sure to wrap your top-level [MaterialApp] in an [Auth] widget to have
  /// access to it later.
  static Config of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Auth>().config;
  }

  @override
  bool updateShouldNotify(Auth old) => false;
}
