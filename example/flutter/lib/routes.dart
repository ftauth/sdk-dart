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

class AdminRouteInformationParser extends RouteInformationParser<RouteInfo> {
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

class AdminRouterDelegate extends RouterDelegate<RouteInfo>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  RouteInfo _routeInfo = HomeRouteInfo();
  Stream<AuthState> authStates;

  AdminRouterDelegate() {
    authStates = FTAuth.instance.authStates.asBroadcastStream();
    authStates.listen((state) {
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
      stream: authStates,
      initialData: const AuthLoading(),
      builder: (context, snapshot) {
        final state = snapshot.data;
        final showAuthScreen = state is! AuthSignedIn;
        return Navigator(
          pages: [
            MaterialPage(
              key: ValueKey('HomeScreen'),
              child: HomeScreen(),
            ),
            if (showAuthScreen)
              MaterialPage(
                key: ValueKey('AuthScreen'),
                child: AuthScreen(_authRouteInfo),
              ),
          ],
          onPopPage: (route, result) => route.didPop(result),
        );
      },
    );
  }

  @override
  RouteInfo get currentConfiguration => _routeInfo;

  @override
  Future<void> setNewRoutePath(RouteInfo configuration) async {
    _routeInfo = configuration;
  }

  AuthRouteInfo get _authRouteInfo {
    if (_routeInfo is AuthRouteInfo) {
      return _routeInfo;
    }
    return AuthRouteInfo.empty();
  }
}
