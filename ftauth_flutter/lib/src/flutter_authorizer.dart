import 'package:flutter/services.dart';
import 'package:ftauth/ftauth.dart';
import 'package:ftauth_flutter/src/storage/secure_storage.dart';
import 'package:ftauth_flutter/src/exception.dart';

class FlutterAuthorizer extends Authorizer {
  static const _channel = MethodChannel('ftauth_flutter');

  FlutterAuthorizer(FTAuthConfig config)
      : super(
          config,
          storageRepo: FlutterSecureStorage.instance,
        );

  /// Log in the user by presenting a WebView.
  Future<Client> login() async {
    final url = await authorize();

    final Map<String, String>? queryParams =
        await _channel.invokeMapMethod<String, String>('login', url);

    if (queryParams == null) {
      throw PlatformException(
        code: PlatformExceptionCodes.unknown,
        message: 'Login process failed.',
      );
    }

    return exchange(queryParams);
  }
}
