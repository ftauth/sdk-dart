import 'dart:convert';

import 'package:ftauth/src/authorizer/keys.dart';
import 'package:ftauth/src/repo/ssl/keys.dart';
import 'package:test/test.dart';
import 'package:http/src/response.dart';
import 'package:ftauth/ftauth.dart';
import 'package:uuid/uuid.dart';

import '../mock/mock_oauth_server.dart';
import '../mock/mock_storage_repo.dart';
import '../mock/mock_http_client.dart';
import '../util/jwt.dart';
import '../util/logger.dart';

void main() {
  FTAuth.logger = const NoOutputLogger();
  final storageRepo = MockStorageRepo();
  late final JwtUtil jwtUtil;
  final baseHttpClient = MockHttpClient(
    userInfoHandler: (_) async {
      final user = User(id: 'test');
      final json = jsonEncode(user.toJson());
      return Response(json, 200);
    },
  );
  late final MockOAuthServer mockOAuthServer;

  const clientId = 'some-client-id';
  final gatewayUri = Uri.parse('http://localhost:8000');
  final redirectUri = Uri.parse('http://localhost:8080/auth');
  final mockPublicConfig = Config(
    gatewayUri: gatewayUri,
    clientType: ClientType.public,
    clientId: clientId,
    redirectUri: redirectUri,
    scopes: ['default'],
    refreshTokenFormat: TokenFormat.custom,
  );

  setUpAll(() async {
    jwtUtil = await JwtUtil.instance;
    mockOAuthServer = MockOAuthServer(jwtUtil);
  });

  setUp(() async {
    await storageRepo.clear();
    mockOAuthServer.reset();
  });

  group('getAuthorizationUrl', () {
    test('with valid public config', () async {
      final authorizer = AuthorizerImpl(
        mockPublicConfig,
        storageRepo: storageRepo,
        configChangeStrategy: ConfigChangeStrategy.clear,
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

      final config = Config(
        gatewayUri: gatewayUri,
        clientType: ClientType.confidential,
        clientId: clientId,
        clientSecret: clientSecret,
        redirectUri: redirectUri,
        scopes: ['default'],
      );

      final authorizer = AuthorizerImpl(
        config,
        storageRepo: storageRepo,
        configChangeStrategy: ConfigChangeStrategy.clear,
      );

      expect(
        authorizer.getAuthorizationUrl(),
        throwsStateError,
      );
    });
  });

  Future<void> setupValidUser() async {
    final accessToken = await jwtUtil.createJWTToken(
      expiration: DateTime.now().add(const Duration(minutes: 5)),
    );
    final refreshToken = Uuid().v4();

    await storageRepo.setEphemeralString(keyFreshInstall, 'flag');
    await storageRepo.setString(keyAccessToken, accessToken);
    await storageRepo.setString(keyRefreshToken, refreshToken);
  }

  group('initState', () {
    test('nothing in storage', () async {
      final authorizer = AuthorizerImpl(
        mockPublicConfig,
        storageRepo: storageRepo,
        configChangeStrategy: ConfigChangeStrategy.clear,
      );

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
        configChangeStrategy: ConfigChangeStrategy.clear,
      );

      expect(
        authorizer.authStates,
        emitsInOrder([
          const AuthSignedOut(),
        ]),
      );
    });

    group('access/refresh token in storage', () {
      test('valid tokens', () async {
        final authorizer = AuthorizerImpl(
          mockPublicConfig,
          storageRepo: storageRepo,
          configChangeStrategy: ConfigChangeStrategy.clear,
          baseClient: baseHttpClient,
        );
        await setupValidUser();

        expect(
          authorizer.authStates,
          emitsInOrder([
            isA<AuthSignedIn>(),
          ]),
        );
      });

      test('fresh install', () async {
        final authorizer = AuthorizerImpl(
          mockPublicConfig,
          storageRepo: storageRepo,
          configChangeStrategy: ConfigChangeStrategy.clear,
          baseClient: baseHttpClient,
        );
        await setupValidUser();
        await storageRepo.delete(keyFreshInstall);

        expect(
          authorizer.authStates,
          emitsInOrder([
            isA<AuthSignedOut>(),
          ]),
        );
      });

      test('expired tokens', () async {
        final httpClient = baseHttpClient.copyWith(
          tokenHandler: (_) async {
            return Response(
              '''
              {
                "error": "invalid_grant",
                "error_description": "The given grant is invalid"
              }
              ''',
              400,
              headers: {'content-type': 'application/json'},
            );
          },
        );
        final authorizer = AuthorizerImpl(
          mockPublicConfig,
          storageRepo: storageRepo,
          configChangeStrategy: ConfigChangeStrategy.clear,
          baseClient: httpClient,
        );
        await setupValidUser();

        final accessToken = await jwtUtil.createJWTToken(
          expiration: DateTime.now().add(const Duration(minutes: -5)),
        );
        await storageRepo.setString(keyAccessToken, accessToken);

        expect(
          authorizer.authStates,
          emitsInOrder([
            isA<AuthSignedOut>(),
          ]),
        );
      });

      test('userinfo call fails', () async {
        final httpClient = baseHttpClient.copyWith(
          userInfoHandler: (_) async => Response('Unauthorized', 401),
        );

        final authorizer = AuthorizerImpl(
          mockPublicConfig,
          storageRepo: storageRepo,
          configChangeStrategy: ConfigChangeStrategy.clear,
          baseClient: httpClient,
        );
        await setupValidUser();

        expect(
          authorizer.authStates,
          emitsInOrder([
            isA<AuthSignedIn>(),
          ]),
        );
      });
    });
  });

  group('authorize', () {
    test('user is logged in', () async {
      final authorizer = AuthorizerImpl(
        mockPublicConfig,
        storageRepo: storageRepo,
        baseClient: baseHttpClient,
        configChangeStrategy: ConfigChangeStrategy.clear,
      );
      await setupValidUser();

      final url = await authorizer.authorize();
      expect(url, '');
    });

    test('returns auth code and modifies state', () async {
      final authorizer = AuthorizerImpl(
        mockPublicConfig,
        storageRepo: storageRepo,
        configChangeStrategy: ConfigChangeStrategy.clear,
        baseClient: baseHttpClient,
      );

      final url = await authorizer.authorize();
      expect(url.isNotEmpty, isTrue);

      final resp = await mockOAuthServer.mockHttpClient.get(Uri.parse(url));
      expect(resp.statusCode, 200);

      final json = jsonDecode(resp.body) as Map;
      expect(json['code'], isNotNull);

      expect(await authorizer.authStates.first, const AuthLoading());
    });
  });

  group('exchange', () {
    test('authorize has not been called', () async {
      final authorizer = AuthorizerImpl(
        mockPublicConfig,
        storageRepo: storageRepo,
        configChangeStrategy: ConfigChangeStrategy.clear,
        baseClient: baseHttpClient,
      );

      expect(authorizer.exchange({}), throwsStateError);
    });

    test('successful exchange', () async {
      final authorizer = AuthorizerImpl(
        mockPublicConfig,
        storageRepo: storageRepo,
        configChangeStrategy: ConfigChangeStrategy.clear,
        baseClient: mockOAuthServer.mockHttpClient,
      );

      final url = await authorizer.authorize();
      expect(url.isNotEmpty, isTrue);

      final resp = await mockOAuthServer.mockHttpClient.get(Uri.parse(url));
      expect(resp.statusCode, 200);

      final json = jsonDecode(resp.body) as Map;
      expect(json['code'], isNotNull);
      expect(json['state'], isNotNull);

      await authorizer.exchange(json.cast());

      expect(await authorizer.authStates.first, isA<AuthSignedIn>());
    });

    test('failedExchange', () async {
      final authorizer = AuthorizerImpl(
        mockPublicConfig,
        storageRepo: storageRepo,
        configChangeStrategy: ConfigChangeStrategy.clear,
        baseClient: mockOAuthServer.mockHttpClient.copyWith(
          tokenHandler: (_) async => Response(
            jsonEncode({paramError: 'Bad Request'}),
            400,
            headers: {'content-type': 'application/json'},
          ),
        ),
      );

      final url = await authorizer.authorize();
      expect(url.isNotEmpty, isTrue);

      final resp = await mockOAuthServer.mockHttpClient.get(Uri.parse(url));
      expect(resp.statusCode, 200);

      final json = jsonDecode(resp.body) as Map;
      expect(json['code'], isNotNull);
      expect(json['state'], isNotNull);

      try {
        await authorizer.exchange(json.cast());
      } on Exception {
        // ignore
      }

      expect(await authorizer.authStates.first, isA<AuthFailure>());
    });
  });

  group('logout', () {
    test('clears correct data', () async {
      await Future.wait([
        storageRepo.setString(keyAccessToken, 'access_token'),
        storageRepo.setString(keyAccessTokenExp, '123456789'),
        storageRepo.setString(keyRefreshToken, 'refresh_token'),
        storageRepo.setString(keyCodeVerifier, 'code_verifier'),
        storageRepo.setString(keyState, 'state'),
        storageRepo.setString(keyConfig, 'config'),
        storageRepo.setString(keyIdToken, 'id_token'),
        storageRepo.setString(keyPinnedCertificates, 'pinned_certs'),
        storageRepo.setString(keyPinnedCertificateChains, 'pinned_cert_chains'),
      ]);

      final authorizer = AuthorizerImpl(
        mockPublicConfig,
        storageRepo: storageRepo,
        configChangeStrategy: ConfigChangeStrategy.clear,
        baseClient: mockOAuthServer.mockHttpClient,
      );
      await authorizer.logout();

      final removedStrings = await Future.wait([
        storageRepo.getString(keyAccessToken),
        storageRepo.getString(keyAccessTokenExp),
        storageRepo.getString(keyRefreshToken),
        storageRepo.getString(keyCodeVerifier),
        storageRepo.getString(keyState),
        storageRepo.getString(keyIdToken),
      ]);
      expect(removedStrings.every((element) => element == null), isTrue);

      final savedStrings = await Future.wait([
        storageRepo.getString(keyPinnedCertificates),
        storageRepo.getString(keyPinnedCertificateChains),
        storageRepo.getString(keyConfig),
      ]);
      expect(savedStrings.every((element) => element != null), isTrue);
    });
  });
}
