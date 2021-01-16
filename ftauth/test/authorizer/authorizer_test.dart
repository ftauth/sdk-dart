import 'package:ftauth/ftauth.dart';
import 'package:test/test.dart';

import '../mock/metadata_repo.dart';
import '../mock/storage_repo.dart';

void main() {
  final storageRepo = MockStorageRepo();
  storageRepo.init();

  final mockMetadataRepo = MockMetadataRepo();

  const clientId = 'some-client-id';
  final mockPublicConfig = FTAuthConfig(
    gatewayUrl: 'http://localhost:8080',
    clientType: ClientType.public,
    clientId: clientId,
    redirectUri: 'http://localhost:8080/auth',
    scopes: ['default'],
  );

  setUp(() {
    storageRepo.clear();
  });

  group('getAuthorizationUrl', () {
    test('with valid public config', () async {
      final authorizer = AuthorizerImpl(
        mockPublicConfig,
        storageRepo: storageRepo,
        metadataRepo: mockMetadataRepo,
      );

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

      final config = FTAuthConfig(
        gatewayUrl: 'http://localhost:8080',
        clientType: ClientType.confidential,
        clientId: clientId,
        clientSecret: clientSecret,
        redirectUri: 'http://localhost:8080/auth',
        scopes: ['default'],
      );

      final authorizer = AuthorizerImpl(
        config,
        storageRepo: storageRepo,
        metadataRepo: mockMetadataRepo,
      );

      expect(
        authorizer.getAuthorizationUrl(),
        throwsStateError,
      );
    });
  });

  group('initState', () {
    test('nothing in storage', () async {
      final authorizer = AuthorizerImpl(
        mockPublicConfig,
        storageRepo: storageRepo,
        metadataRepo: mockMetadataRepo,
      );

      final authState = await authorizer.init();
      expect(authState, AuthSignedOut());
      expect(
        authorizer.authStates,
        emitsInOrder([
          const AuthSignedOut(),
        ]),
      );
    });

    test('state/code verifier in storage', () async {
      final authorizer = AuthorizerImpl(
        mockPublicConfig,
        storageRepo: storageRepo,
        metadataRepo: mockMetadataRepo,
      );

      final authState = await authorizer.init();
      expect(authState, AuthSignedOut());
      expect(
        authorizer.authStates,
        emitsInOrder([
          const AuthSignedOut(),
        ]),
      );
    });

    test('access/refresh token in storage', () async {
      final authorizer = AuthorizerImpl(
        mockPublicConfig,
        storageRepo: storageRepo,
        metadataRepo: mockMetadataRepo,
      );

      await storageRepo.setString('access_token', 'token');
      await storageRepo.setString('refresh_token', 'token');

      final authState = await authorizer.init();
      expect(authState, isA<AuthSignedIn>());
      expect(
        authorizer.authStates,
        emitsInOrder([
          isA<AuthSignedIn>(),
        ]),
      );
    });
  });
}
