import 'dart:math';

import 'package:ftauth_jwt/ftauth_jwt.dart';

/// Utilities for performing the OAuth 2.0 flow.
class OAuthUtil {
  static final _random = Random.secure();

  /// Generates a random state parameter for the auth code flow.
  static String generateState() {
    const _stateLength = 24;
    final bytes = <int>[];
    for (var i = 0; i < _stateLength; i++) {
      final value = _random.nextInt(255);
      bytes.add(value);
    }

    return base64RawUrl.encode(bytes);
  }

  /// Generates a random code verifier for the auth code flow.
  static String createCodeVerifier() {
    const length = 128;
    const characterSet =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~';
    var codeVerifier = '';
    for (var i = 0; i < length; i++) {
      codeVerifier += characterSet[_random.nextInt(characterSet.length)];
    }
    return codeVerifier;
  }
}
