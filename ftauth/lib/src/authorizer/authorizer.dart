import 'dart:async';

import 'package:ftauth/ftauth.dart';
import 'package:ftauth/src/metadata/metadata_repo.dart';
import 'package:ftauth/src/metadata/metadata_repo_impl.dart';
import 'package:meta/meta.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:uuid/uuid.dart';

abstract class Authorizer {
  late final Config config;

  late MetadataRepo metadataRepo;
  final Completer<Client> clientCompleter = Completer<Client>();
  oauth2.AuthorizationCodeGrant? authCodeGrant;

  Authorizer(this.config) : metadataRepo = MetadataRepoImpl(config);

  // Platform-specific implementations

  @visibleForTesting
  Future<void> launchUrl(String url) {
    throw UnimplementedError();
  }

  // Common implementations

  Future<Client> authorize() async {
    if (config.clientType == ClientType.confidential) {
      throw UnsupportedError(
          'Confidential clients cannot be used in web applications.');
    }
    final authorizationUrl = await getAuthorizationUrl();
    await launchUrl(authorizationUrl);

    return clientCompleter.future;
  }

  @visibleForTesting
  Future<Client> authorizeConfidentialClient() async {
    final client = await oauth2.clientCredentialsGrant(
      config.authorizationUri,
      config.clientId,
      config.clientSecret,
    );
    final keyStore = await metadataRepo.loadKeyStore();
    final credentials = await Credentials.fromOAuthCredentials(
      client.credentials,
      keyStore,
      config.scopes!,
    );
    final newClient = Client(credentials: credentials);
    clientCompleter.complete(newClient);
    return newClient;
  }

  @visibleForTesting
  Future<String> getAuthorizationUrl() async {
    if (config.clientType == ClientType.confidential) {
      throw StateError(
        'Confidential clients must use client credentials flow',
      );
    }

    final state = Uuid().v4();
    authCodeGrant = oauth2.AuthorizationCodeGrant(
      config.clientId,
      config.authorizationUri,
      config.tokenUri,
    );
    return authCodeGrant!
        .getAuthorizationUrl(
          config.redirectUri,
          scopes: config.scopes,
          state: state,
        )
        .toString();
  }

  Future<Client> exchangeAuthorizationCode(
    Map<String, String> parameters,
    List<String> scopes,
  ) async {
    if (authCodeGrant == null) {
      throw StateError('Must call getAuthorizationUrl first.');
    }
    final client = await authCodeGrant!.handleAuthorizationResponse(parameters);
    final keyStore = await metadataRepo.loadKeyStore();
    final credentials = await Credentials.fromOAuthCredentials(
      client.credentials,
      keyStore,
      scopes,
    );
    final newClient = Client(credentials: credentials);
    clientCompleter.complete(newClient);
    return newClient;
  }
}
