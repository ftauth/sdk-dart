/// Utilities for performing the OAuth 2.0 flow.
library ftauth.util.oauth;

import 'dart:convert';
import 'dart:math';

import 'package:ftauth/ftauth.dart';
import 'package:ftauth_jwt/ftauth_jwt.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:http/http.dart' as http;

final _random = Random.secure();

/// Generates a random state parameter for the auth code flow.
String generateState() {
  const _stateLength = 24;
  final bytes = <int>[];
  for (var i = 0; i < _stateLength; i++) {
    final value = _random.nextInt(255);
    bytes.add(value);
  }

  return base64RawUrl.encode(bytes);
}

/// Generates a random code verifier for the auth code flow.
String createCodeVerifier() {
  const length = 128;
  const characterSet =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~';
  var codeVerifier = '';
  for (var i = 0; i < length; i++) {
    codeVerifier += characterSet[_random.nextInt(characterSet.length)];
  }
  return codeVerifier;
}

/// Creates an authorization code grant.
oauth2.AuthorizationCodeGrant createGrant(
  Config config, {
  String? codeVerifier,
  http.Client? httpClient,
}) {
  return oauth2.AuthorizationCodeGrant(
    config.clientId,
    config.authorizationUri,
    config.tokenUri,
    // Must be included as empty string so that the client ID is sent
    // in requests.
    secret: config.clientSecret ?? '',
    httpClient: httpClient,
    codeVerifier: codeVerifier,
  );
}

/// Creates an authorization code grant and advances the internal state to
/// `pendingResponse` so that parameter exchange will work.
oauth2.AuthorizationCodeGrant restoreGrant(
  Config config, {
  required String state,
  String? codeVerifier,
  http.Client? httpClient,
}) {
  final grant = createGrant(
    config,
    codeVerifier: codeVerifier,
    httpClient: httpClient,
  );

  // Advances the internal state.
  grant.getAuthorizationUrl(
    config.redirectUri,
    scopes: config.scopes,
    state: state,
  );
  return grant;
}

// Creates a `Basic` authorization header for identifiying clients.
String createBasicAuthorization(String clientId, [String? clientSecret]) {
  clientSecret ??= '';
  return 'Basic ' + base64Encode('$clientId:$clientSecret'.codeUnits);
}
