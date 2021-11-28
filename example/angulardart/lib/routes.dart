import 'package:angular_router/angular_router.dart';

import 'auth/auth_component.template.dart' as auth_component;
import 'login/login_component.template.dart' as login_component;
import 'todos/todos_component.template.dart' as todos_component;

class RoutePaths {
  static final login = RoutePath(path: 'login');
  static final auth = RoutePath(path: 'auth');
  static final todos = RoutePath(path: '');
}

class Routes {
  static final login = RouteDefinition(
    routePath: RoutePaths.login,
    component: login_component.LoginComponentNgFactory,
  );

  static final auth = RouteDefinition(
    routePath: RoutePaths.auth,
    component: auth_component.AuthComponentNgFactory,
    useAsDefault: true,
  );

  static final todos = RouteDefinition(
    routePath: RoutePaths.todos,
    component: todos_component.TodosComponentNgFactory,
  );

  static final all = [
    auth,
    login,
    todos,
  ];
}
