import 'package:ftauth/ftauth.dart';

export 'authorizer_stub.dart'
    if (dart.library.io) 'authorizer_io.dart'
    if (dart.library.html) 'authorizer_html.dart';

abstract class AuthorizerInterface {
  Future<void> init();
  Future<String> authorize({
    String? language,
    String? countryCode,
  });
  Future<Client> exchange(Map<String, String> parameters);
  Future<void> login({
    String? language,
    String? countryCode,
  });
  Future<void> logout();
  AuthState get currentState;
}
