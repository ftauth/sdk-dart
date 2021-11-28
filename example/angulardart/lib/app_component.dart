import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'routes.dart';

@Component(
  selector: 'app',
  templateUrl: 'app_component.html',
  styleUrls: [
    'app_component.css',
  ],
  directives: [
    routerDirectives,
  ],
  exports: [Routes, RoutePaths],
)
class AppComponent {}
