import 'package:ftauth/src/dpop/dpop_repo.dart';
import 'package:ftauth/src/http/dpop_client.dart';
import 'package:ftauth/src/jwt/keyset.dart';
import 'package:ftauth/src/crypto/crypto_key.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:http/http.dart' as http;

import 'jwt/token.dart';
import 'model/user/user.dart';

/// A user's access and refresh tokens plus metadata needed to access services.
class Credentials implements oauth2.Credentials {
  final Uri _tokenEndpoint;
  final JsonWebToken _accessToken;
  final JsonWebToken _refreshToken;
  final JsonWebKeySet _keySet;
  final List<String> _scopes;
  final Function(dynamic e) _onError;

  Credentials(
    this._accessToken,
    this._refreshToken,
    this._tokenEndpoint,
    this._keySet,
    this._scopes, {
    required Function(dynamic e) onError,
  }) : _onError = onError;

  static Future<Credentials> fromOAuthCredentials(
    oauth2.Credentials creds,
    JsonWebKeySet keySet,
    List<String> scopes, {
    required Function(dynamic e) onError,
  }) async {
    final accessToken = JsonWebToken.parse(creds.accessToken);
    await accessToken.verify(keySet, verifierFactory: (key) => key.verifier);

    final refreshToken = JsonWebToken.parse(creds.refreshToken!);
    await refreshToken.verify(keySet, verifierFactory: (key) => key.verifier);

    return Credentials(
      accessToken,
      refreshToken,
      creds.tokenEndpoint!,
      keySet,
      scopes,
      onError: onError,
    );
  }

  User get user {
    return _accessToken.user!;
  }

  @override
  String get accessToken => _accessToken.raw;

  @override
  bool get canRefresh =>
      _refreshToken.claims.expiration!.isAfter(DateTime.now());

  @override
  DateTime get expiration => _accessToken.claims.expiration!;

  @override
  String? get idToken => null;

  @override
  bool get isExpired =>
      _accessToken.claims.expiration!.isBefore(DateTime.now());

  @override
  String get refreshToken => _refreshToken.raw;

  @override
  List<String> get scopes => _scopes;

  @override
  String toJson() => '';

  @override
  Uri get tokenEndpoint => _tokenEndpoint;

  @override
  Future<oauth2.Credentials> refresh({
    String? identifier,
    String? secret,
    Iterable<String>? newScopes,
    bool basicAuth = true,
    http.Client? httpClient,
  }) async {
    try {
      final creds = await oauth2.Credentials(
        accessToken,
        refreshToken: refreshToken,
        tokenEndpoint: _tokenEndpoint,
        scopes: scopes,
      ).refresh(
        identifier: identifier,
        secret: secret,
        httpClient: DPoPClient(DPoPRepo.instance),
      );
      return fromOAuthCredentials(creds, _keySet, _scopes, onError: _onError);
    } catch (e) {
      _onError(e);
      return this;
    }
  }
}
