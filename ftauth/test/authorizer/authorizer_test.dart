import 'package:ftauth/ftauth.dart';
import 'package:test/test.dart';

import '../mock/metadata_repo.dart';
import '../mock/storage_repo.dart';

const _accessToken =
    'eyJ0eXAiOiJhdCtqd3QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiJkaWxsb25ueXMiLCJjbGllbnRfaWQiOiJlZTFkZTVhZC1jNGE4LTQxNWMtOGZmNi03NjljYTBmZDNiZjEiLCJleHAiOjE2MTA4MzY2NjgsImlhdCI6MTYxMDgzMzA2OCwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo4MDgwIiwianRpIjoiOTI0OTdkMGQtOWE2MS00NzM5LTk3MjktM2RjMzc2YTNmYzFjIiwic2NvcGUiOiJkZWZhdWx0Iiwic3ViIjoiZWUxZGU1YWQtYzRhOC00MTVjLThmZjYtNzY5Y2EwZmQzYmYxIiwidXNlckluZm8iOnsiaWQiOiJkaWxsb25ueXMiLCJ1c2VybmFtZSI6IiIsImZpcnN0X25hbWUiOiIiLCJsYXN0X25hbWUiOiIiLCJlbWFpbCI6IiIsInBob25lX251bWJlciI6IiIsInByb3ZpZGVyIjoiIn19.ryi-Lq_0u1B-NkPeY6znN7dypPG68SwPGMhXdVm655gN32MPcS5LGycP0F-9qW-nstYKP9n9xwxDcX-GTidaHFfogk74CkwXydTjGq9DkaPQMdYdYbJ0Se6pcSu4AM6m6yc4JQorOYfdnlm24mXJtua8PBa48rQKfgdRx-ZYPFicvGhUkqduztz0s9bVIa6ZKQS11wWrsZGTeBZbkqj4DBmpNXJe4JvgUQh06eaVMWyhZ2dRSLSsHXeKx6C2c8gsSw9-xKqMgR3Ija8pvpfQQ9_CKofmaz0WEbdCXxRE_ymXGAHuLygOl0aNrmdEy6EpG6IcgFMhQO9KurJ4KHcfGA';
const _refreshToken =
    'eyJ0eXAiOiJhdCtqd3QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI5MjQ5N2QwZC05YTYxLTQ3MzktOTcyOS0zZGMzNzZhM2ZjMWMiLCJjbGllbnRfaWQiOiJlZTFkZTVhZC1jNGE4LTQxNWMtOGZmNi03NjljYTBmZDNiZjEiLCJleHAiOjE2MTA5MTk0NjgsImlhdCI6MTYxMDgzMzA2OCwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo4MDgwIiwianRpIjoiODgyNjY5ZTEtNGM5My00MDIxLTkyOTMtZDI5ZWFjNGVjYzlmIiwic2NvcGUiOiJkZWZhdWx0Iiwic3ViIjoiZWUxZGU1YWQtYzRhOC00MTVjLThmZjYtNzY5Y2EwZmQzYmYxIiwidXNlckluZm8iOnsiaWQiOiJkaWxsb25ueXMiLCJ1c2VybmFtZSI6IiIsImZpcnN0X25hbWUiOiIiLCJsYXN0X25hbWUiOiIiLCJlbWFpbCI6IiIsInBob25lX251bWJlciI6IiIsInByb3ZpZGVyIjoiIn19.m4CBZrPkoYxqyYjZ0eIEZ3hk4OCfcwU-m1JCSmqD_v-xdhbW4r-yzg1-0XF6Nn7fKi4-j2tzNsuCIQdyyeCk490BOahhQlhhUiQKDudGSFCFUQrkx6xAlYkfslsUKrbGfq4qHH5JGNpm1lY6aN9928oiLkEAc6YS-m8uJrJ5-VC5VHeijioX8sWVIMldblUgAeEN_F4eHEF7tkVAQ1cVDMhmTPR9of2ZLS4csTi38BqE0BEdwZjDeAA_14VeSVyiocPxUEr9nz5ckYmQvVf-brHBD08Z5SSiKmukghIV33q7Qa9keqE8mWtNUphyl9D909ivAjLkcEk8AktHZF-kMQ';

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
      final authorizer = Authorizer(
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

      final authorizer = Authorizer(
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
      final authorizer = Authorizer(
        mockPublicConfig,
        storageRepo: storageRepo,
        metadataRepo: mockMetadataRepo,
      );

      final authState = await authorizer.authStates.first;
      expect(authState, AuthSignedOut());
      expect(
        authorizer.authStates,
        emitsInOrder([
          const AuthSignedOut(),
        ]),
      );
    });

    test('state/code verifier in storage', () async {
      final authorizer = Authorizer(
        mockPublicConfig,
        storageRepo: storageRepo,
        metadataRepo: mockMetadataRepo,
      );

      final authState = await authorizer.authStates.first;
      expect(authState, AuthSignedOut());
      expect(
        authorizer.authStates,
        emitsInOrder([
          const AuthSignedOut(),
        ]),
      );
    });

    test('access/refresh token in storage', () async {
      final authorizer = Authorizer(
        mockPublicConfig,
        storageRepo: storageRepo,
        metadataRepo: mockMetadataRepo,
      );

      await storageRepo.setString('access_token', _accessToken);
      await storageRepo.setString('refresh_token', _refreshToken);

      final authState = await authorizer.authStates.first;
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
