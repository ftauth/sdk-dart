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
  changeDetection: ChangeDetectionStrategy.OnPush,
)
class AppComponent implements OnInit {
  AppComponent(this.ref);

  final ChangeDetectorRef ref;

  @override
  void ngOnInit() {
    // ref.ma
  }
}
