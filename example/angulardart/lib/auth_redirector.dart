import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angulardart/routes.dart';
import 'package:ftauth/ftauth.dart';
import 'package:meta/meta.dart';

mixin AuthRedirector implements OnInit {
  Router get router;
  FTAuth get ftauth;

  @override
  @mustCallSuper
  void ngOnInit() async {
    ftauth.authStates.listen((event) {
      if (event is! AuthSignedIn) {
        router.navigate(RoutePaths.login.path);
        return;
      }
      if (router.current?.path != RoutePaths.todos.path) {
        router.navigate(RoutePaths.todos.path);
      }
    });
  }
}
