import 'package:ftauth/ftauth.dart' as ftauth;
import 'package:ftauth/src/authorizer/authorizer_stub.dart'
    if (dart.library.io) 'package:ftauth/src/authorizer/authorizer_io.dart'
    if (dart.library.html) 'package:ftauth/src/authorizer/authorizer_html.dart';
import 'package:test/test.dart';

void main() {
  group('getAuthorizationUrl', () {
    test('with valid public config', () async {
      const clientId = 'some-client-id';
      final config = ftauth.Config(
        gatewayUrl: 'http://localhost:8080',
        clientType: ftauth.ClientType.public,
        clientId: clientId,
        redirectUri: 'http://localhost:8080/auth',
        scopes: ['default'],
      );

      final authorizer = AuthorizerImpl(config);

      final authorizationUrl = await authorizer.getAuthorizationUrl();
      final authorizationUri = Uri.parse(authorizationUrl);

      expect(authorizationUri.pathSegments.last, 'authorize');

      expect(authorizationUri.queryParameters['state'], isNotNull);
      expect(authorizationUri.queryParameters['state'], isNotEmpty);

      expect(authorizationUri.queryParameters['redirect_uri'], isNotNull);
      expect(authorizationUri.queryParameters['redirect_uri'], isNotEmpty);

      expect(authorizationUri.queryParameters['scope'], isNotNull);
      expect(authorizationUri.queryParameters['scope'], isNotEmpty);

      expect(authorizationUri.queryParameters['response_type'], 'code');
      expect(authorizationUri.queryParameters['client_id'], clientId);

      expect(authorizationUri.queryParameters['code_challenge'], isNotNull);
      expect(authorizationUri.queryParameters['code_challenge'], isNotEmpty);

      expect(
        authorizationUri.queryParameters['code_challenge_method'],
        'S256',
      );
    });

    test('with valid confidential config', () async {
      const clientId = 'some-client-id';
      const clientSecret = 'some-client-secret';

      final config = ftauth.Config(
        gatewayUrl: 'http://localhost:8080',
        clientType: ftauth.ClientType.confidential,
        clientId: clientId,
        clientSecret: clientSecret,
        redirectUri: 'http://localhost:8080/auth',
        scopes: ['default'],
      );

      final authorizer = AuthorizerImpl(config);

      expect(
        authorizer.getAuthorizationUrl(),
        throwsStateError,
      );
    });
  });
}
