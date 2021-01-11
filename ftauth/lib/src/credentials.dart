import 'package:jose/jose.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:http/http.dart' as http;

import 'model/user/user.dart';

/// A user's access and refresh tokens plus metadata needed to access services.
class Credentials implements oauth2.Credentials {
  final Uri _tokenEndpoint;
  final JsonWebToken _accessToken;
  final JsonWebToken _refreshToken;
  final JsonWebKeyStore _keyStore;
  final List<String> _scopes;

  Credentials(
    this._accessToken,
    this._refreshToken,
    this._tokenEndpoint,
    this._keyStore,
    this._scopes,
  );

  static Future<Credentials> fromOAuthCredentials(
    oauth2.Credentials creds,
    JsonWebKeyStore keyStore,
    List<String> scopes,
  ) async {
    final accessToken = await JsonWebToken.decodeAndVerify(
      creds.accessToken,
      keyStore,
    );
    final refreshToken = await JsonWebToken.decodeAndVerify(
      creds.refreshToken,
      keyStore,
    );
    return Credentials(
      accessToken,
      refreshToken,
      creds.tokenEndpoint,
      keyStore,
      scopes,
    );
  }

  User get user {
    final userInfo =
        _accessToken.claims.getTyped<Map<String, dynamic>>('userInfo');
    return User.fromJson(userInfo);
  }

  @override
  String get accessToken => _accessToken.toCompactSerialization();

  @override
  bool get canRefresh => _refreshToken.claims.expiry.isAfter(DateTime.now());

  @override
  DateTime get expiration => _accessToken.claims.expiry;

  @override
  String? get idToken => null;

  @override
  bool get isExpired => _accessToken.claims.expiry.isBefore(DateTime.now());

  @override
  Future<Credentials> refresh({
    required String identifier,
    String? secret,
    Iterable<String>? newScopes,
    bool basicAuth = true,
    http.Client? httpClient,
  }) async {
    final creds = await oauth2.Credentials(
      accessToken,
      refreshToken: refreshToken,
      tokenEndpoint: _tokenEndpoint,
      scopes: scopes,
    ).refresh(
      identifier: identifier,
      secret: secret,
      httpClient: httpClient,
    );
    return fromOAuthCredentials(creds, _keyStore, _scopes);
  }

  @override
  String get refreshToken => _refreshToken.toCompactSerialization();

  @override
  List<String> get scopes => _scopes;

  @override
  String toJson() => '';

  @override
  Uri get tokenEndpoint => _tokenEndpoint;
}
