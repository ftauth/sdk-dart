import 'package:ftauth/ftauth.dart';
import 'package:test/test.dart';

import '../mock/metadata_repo.dart';
import '../mock/storage_repo.dart';

const _accessToken =
    'eyJ0eXAiOiJhdCtqd3QiLCJhbGciOiJQUzI1NiJ9.eyJhdWQiOiIzY2Y5YTdhYy05MTk4LTQ2OWUtOTJhNy1jYzJmMTVkOGI4N2QiLCJjbGllbnRfaWQiOiIzY2Y5YTdhYy05MTk4LTQ2OWUtOTJhNy1jYzJmMTVkOGI4N2QiLCJjbmYiOnsiamt0IjoiOXJBWEp1ckZTYjgzalFoQ0ZxUDFMYXpieXdFVFVoVmtJT0ZTbGU3eF9TYyJ9LCJleHAiOjE2MTM4NzE0NzksImlhdCI6MTYxMzg2Nzg3OSwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo4MDgwIiwianRpIjoiYjZiMzA5NGItZjc4MS00ZjIzLThlNjktYWI4ZWZjYzgxNDI5Iiwic2NvcGUiOiJkZWZhdWx0Iiwic3ViIjoiRGlsbG9uIiwidXNlckluZm8iOnsiaWQiOiJEaWxsb24ifX0.RwlYGGRM0VUPPOfh2CdjmuJIGIcUrVPjoKUzAi0epuQ430QXPpYQintemBhLODURdhm278C1r-Ts_labwd19HBKdtAePWs9P1ZySBzW72EmAP_w7Gb7QjZkiQ7grHr54VBWxugkWCzgMMTc4M2d0BSPD6LqTb2ii9NpFefTwXbNThf19AXjC7QfXdpeb3FW7RdqKI_YBX-putRPQkRYR0jHVs-pUYmmz3Nnk4UZXo5Yla844KivVxxVwKXmkK2Zg6HDxjBOHUWrl5oNWJ5dwRxnKev5v4AF58sRi4W1SpwXtN7HK7L1evGVTgWp4RQDszeUPbMEjLAOrVlF9PfZ79PeU_zQBnOVXhAi2T-i5mKSKRlADLoHy6XNFxC0gU9T1_u2ILANLfT16sVy3R2PBP5vF57gC6IrcfM-cDRPzNtrk3oJi5RhzjYve9hEV-P6p8aTXq0Z7ZpKX84BfGy1iahRxearoHPYxpGBhbfH6lWmWaf7Dy5KLbYfjNcqNXCi7YjN59c_emYzN-sRF_R8wv16GAy1AYDSA5zDoeGt92kehtgXrWYgdRd8-SZjyYtsNJY3v-ISseE3WMkv3b60vYZdvn-L2It3zgH-EGnIp02YHHbMmrECH7Pao_mE1bvmlktiS0yN9s6wfo6ckGXZ46r6uwLNTCFKMTyaqPJ5iqzk';
const _refreshToken =
    'eyJ0eXAiOiJhdCtqd3QiLCJhbGciOiJQUzI1NiJ9.eyJhdWQiOiIzY2Y5YTdhYy05MTk4LTQ2OWUtOTJhNy1jYzJmMTVkOGI4N2QiLCJjbGllbnRfaWQiOiIzY2Y5YTdhYy05MTk4LTQ2OWUtOTJhNy1jYzJmMTVkOGI4N2QiLCJjbmYiOnsiamt0IjoiOXJBWEp1ckZTYjgzalFoQ0ZxUDFMYXpieXdFVFVoVmtJT0ZTbGU3eF9TYyJ9LCJleHAiOjE2MTM5NTQyNzksImlhdCI6MTYxMzg2Nzg3OSwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo4MDgwIiwianRpIjoiODNjMTZjNzQtMzc0MS00Njk4LTgwNjMtNzVhNWY4MDcwMThlIiwic2NvcGUiOiJkZWZhdWx0Iiwic3ViIjoiYjZiMzA5NGItZjc4MS00ZjIzLThlNjktYWI4ZWZjYzgxNDI5IiwidXNlckluZm8iOnsiaWQiOiIzY2Y5YTdhYy05MTk4LTQ2OWUtOTJhNy1jYzJmMTVkOGI4N2QifX0.kLI3tQWx-SNlDgB7XVv37Xk5XIbVQaIjKiIrnlVV6a4hOwwISr0XIY4fostdfpDnJF_Jq1C9RGQ85JMPkK2dJJTeKYiTeE7GDv_fr5kSLCZlQLyDPZtoJiVbxMcQBoRddZKqVepq__HyX-pqrXZxtRIu8l5Ha1nTXMpaZaql7yo9i8S10s76pLbKHEKldy8IUOurYz7jePS1W5-vzzL0spII7dHBB8EF9qlPOajSo4prQD6f7Qrolg2Kg4mV1yx8byk2-m4W6gPI7Tg7LSauZiQOSdu4Tn0FpJKAhLG5xZYaIoYV9CmWM2KY6pEsaqbgv96J3Kb8vF_Px3vXklU7WI9bgOyyh4DMYxGEiZbSbw7yYREYAdnTGDStxMifFw9XSloVMs-ZbTH5XX9SRony0ufozmPZQGN4d8X13B8bCXyEOuq9neNzsMpkMOhQRyAUpRRjBIoOFuzTyBLlGTuLpb_GwrRUN7PSbjq6nGKqOUuW41WOWOMG_Tt3xMnrEeT-SeSPjNakFktuaLMXp1O1vCmZxDsPyJP4DCgQLFAMFRHf6rlsEu6lSrVwSjD_FSWRutgj-I6DvcwPcSAXTYWanlCFnZiMpVNPSi5GfUPIxf-ZrF5bKNYATMGaw4j0ITVvbsTe7ZQDTh56YxAKz7w0fKqCXTSDS3gW2rN9eIj9GL8';

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
