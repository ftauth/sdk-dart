import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angulardart/auth_redirector.dart';
import 'package:ftauth/ftauth.dart';

@Component(
  selector: 'auth',
  templateUrl: 'auth_component.html',
  styleUrls: [
    'auth_component.css',
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
)
class AuthComponent with AuthRedirector {
  AuthComponent(this.ftauth, this.router);

  @override
  final FTAuth ftauth;

  @override
  final Router router;
}
