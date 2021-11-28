import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angulardart/auth_redirector.dart';
import 'package:ftauth/ftauth.dart';

@Component(
  selector: 'login',
  templateUrl: 'login_component.html',
  styleUrls: [
    'login_component.css',
  ],
)
class LoginComponent with AuthRedirector {
  LoginComponent(this.ftauth, this.router);

  @override
  final Router router;

  @override
  final FTAuth ftauth;

  Future<void> login() async {
    await ftauth.login();
  }
}
