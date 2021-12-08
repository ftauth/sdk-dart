import 'package:pigeon/pigeon.dart';

class ClientConfiguration {
  String? authorizationEndpoint;

  String? tokenEndpoint;

  String? clientId;

  String? clientSecret;

  String? redirectUri;

  List<String?>? scopes;

  String? state;

  String? codeVerifier;
}

@HostApi()
abstract class NativeLogin {
  @async
  Map<String, String> login(ClientConfiguration config);
}
