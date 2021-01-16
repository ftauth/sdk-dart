import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ftauth_flutter/ftauth_flutter.dart';

import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

abstract class RouteInfo {
  const RouteInfo();
}

class HomeRouteInfo extends RouteInfo {}

class AuthRouteInfo extends RouteInfo {
  final String code;
  final String state;

  const AuthRouteInfo(this.code, this.state);

  const AuthRouteInfo.empty()
      : code = null,
        state = null;

  bool get isEmpty => code == null && state == null;

  Map<String, String> get parameters => {
        'code': code,
        'state': state,
      };
}

class AuthRouteInfoParser extends RouteInformationParser<AuthRouteInfo> {
  @override
  SynchronousFuture<AuthRouteInfo> parseRouteInformation(
      RouteInformation routeInformation) {
    final uri = Uri.parse(routeInformation.location);
    if (uri.queryParameters.containsKey('code') &&
        uri.queryParameters.containsKey('state')) {
      return SynchronousFuture(
        AuthRouteInfo(
          uri.queryParameters['code'],
          uri.queryParameters['state'],
        ),
      );
    }
    return SynchronousFuture(AuthRouteInfo.empty());
  }

  @override
  RouteInformation restoreRouteInformation(RouteInfo configuration) {
    return RouteInformation(location: '/auth');
  }
}

class AppRouteInformationParser extends RouteInformationParser<RouteInfo> {
  final AuthRouteInfoParser _authParser = AuthRouteInfoParser();

  @override
  SynchronousFuture<RouteInfo> parseRouteInformation(
      RouteInformation routeInformation) {
    final uri = Uri.parse(routeInformation.location);
    final pathComponents = uri.pathSegments;
    if (pathComponents.isEmpty) {
      return SynchronousFuture(HomeRouteInfo());
    }
    switch (pathComponents[0]) {
      case 'auth':
        return _authParser.parseRouteInformation(routeInformation);
      default:
        return SynchronousFuture(HomeRouteInfo());
    }
  }

  @override
  RouteInformation restoreRouteInformation(RouteInfo configuration) {
    switch (configuration.runtimeType) {
      case AuthRouteInfo:
        return _authParser.restoreRouteInformation(configuration);
    }

    return RouteInformation(location: '/');
  }
}

class AppRouterDelegate extends RouterDelegate<RouteInfo>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final FTAuthConfig _config;

  RouteInfo _routeInfo = HomeRouteInfo();

  AppRouterDelegate(this._config) {
    _config.authStates.listen((state) {
      final showAuthScreen = state is! AuthSignedIn;
      if (showAuthScreen) {
        _routeInfo = AuthRouteInfo.empty();
      } else {
        _routeInfo = HomeRouteInfo();
      }
      notifyListeners();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FTAuth.of(context).authStates,
      initialData: const AuthLoading(),
      builder: (context, snapshot) {
        final state = snapshot.data;
        final showAuthScreen = state is! AuthSignedIn;
        return Navigator(
          pages: [
            MaterialPage(
              key: ValueKey('HomeScreen'),
              child: const HomeScreen(),
            ),
            if (showAuthScreen)
              MaterialPage(
                key: ValueKey('AuthScreen'),
                child: const AuthScreen(),
              ),
          ],
          onPopPage: (route, result) => route.didPop(result),
        );
      },
    );
  }

  @override
  RouteInfo get currentConfiguration {
    return _routeInfo;
  }

  @override
  Future<void> setNewRoutePath(RouteInfo configuration) async {
    _routeInfo = configuration;

    if (_routeInfo is AuthRouteInfo) {
      final authRouteInfo = _routeInfo as AuthRouteInfo;
      if (!authRouteInfo.isEmpty) {
        _config.exchangeAuthorizationCode(authRouteInfo.parameters);
      }
    }
  }
}
