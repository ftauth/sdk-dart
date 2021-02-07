import 'package:flutter/services.dart';
import 'package:ftauth/ftauth.dart';
import 'package:ftauth_flutter/src/storage/secure_storage.dart';

class FlutterAuthorizer extends Authorizer {
  static const _channel = MethodChannel('ftauth_flutter');

  FlutterAuthorizer(FTAuthConfig config)
      : super(
          config,
          storageRepo: FlutterSecureStorage.instance,
        );

  Future<Client> login() async {
    final url = await authorize();

    final Map<String, String>? queryParams =
        await _channel.invokeMapMethod<String, String>('login', url);

    if (queryParams == null) {
      throw PlatformException(code: 'LOGIN_FAILED');
    }

    return exchange(queryParams);
  }
}
