import 'package:ftauth/ftauth.dart';
import 'package:ftauth/src/authorizer/keys.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:http/http.dart' as http;

/// A user's access and refresh tokens plus metadata needed to access services.
///
/// The base oauth2 implementation is extended to provided extra functionality
/// around the refresh process, including being alerted to errors and verifying,
/// cryptographically, the tokens received.
class Credentials implements oauth2.Credentials {
  final StorageRepo _storageRepo;
  final Config _config;
  final Token _accessToken;
  final Token? _refreshToken;
  final Token? _idToken;
  final List<String> _scopes;
  final http.Client _httpClient;

  Credentials(
    this._accessToken,
    this._refreshToken,
    this._config, {
    Token? idToken,
    required StorageRepo storageRepo,
    required http.Client httpClient,
  })  : _idToken = idToken,
        _storageRepo = storageRepo,
        _scopes = _config.scopes,
        _httpClient = httpClient;

  static Credentials fromOAuthCredentials(
    oauth2.Credentials creds, {
    required Config config,
    required StorageRepo storageRepo,
    required http.Client httpClient,
  }) {
    final accessToken = Token(
      creds.accessToken,
      type: config.accessTokenFormat,
      expiry: config.accessTokenFormat != TokenFormat.JWT ? creds.expiration : null,
    );
    Token? refreshToken;
    if (creds.refreshToken != null) {
      refreshToken = Token(
        creds.refreshToken!,
        type: config.refreshTokenFormat,
      );
    }
    Token? idToken;
    if (creds.idToken != null) {
      idToken = Token(creds.idToken!, type: TokenFormat.JWT);
    }

    return Credentials(
      accessToken,
      refreshToken,
      config,
      idToken: idToken,
      storageRepo: storageRepo,
      httpClient: httpClient,
    );
  }

  @override
  String get accessToken => _accessToken.raw;

  @override
  bool get canRefresh => _refreshToken != null;

  @override
  DateTime? get expiration => _accessToken.expiry;

  int? get expirationSecondsSinceEpoch => expiration != null ? expiration!.millisecondsSinceEpoch ~/ 1000 : null;

  @override
  String? get idToken => _idToken?.raw;

  @override
  bool get isExpired => _accessToken.isExpired;

  @override
  String? get refreshToken => _refreshToken?.raw;

  @override
  List<String> get scopes => _scopes;

  @override
  String toJson() => '';

  @override
  Uri get tokenEndpoint => _config.tokenUri;

  @override
  Future<oauth2.Credentials> refresh({
    String? identifier,
    String? secret,
    Iterable<String>? newScopes,
    bool basicAuth = true,
    http.Client? httpClient,
  }) async {
    FTAuth.debug('Refreshing tokens...');

    try {
      final oauthCreds = await oauth2.Credentials(
        accessToken,
        refreshToken: refreshToken,
        expiration: _accessToken.expiry,
        idToken: idToken,
        tokenEndpoint: _config.tokenUri,
        scopes: scopes,
      ).refresh(
        identifier: identifier,
        secret: secret,
        httpClient: _httpClient,
      );

      final creds = fromOAuthCredentials(
        oauthCreds,
        config: _config,
        storageRepo: _storageRepo,
        httpClient: _httpClient,
      );

      await Future.wait([
        _storageRepo.setString(keyAccessToken, creds.accessToken),
        if (creds.expirationSecondsSinceEpoch != null)
          _storageRepo.setString(
            keyAccessTokenExp,
            creds.expirationSecondsSinceEpoch!.toString(),
          ),
        if (creds.refreshToken != null) _storageRepo.setString(keyRefreshToken, creds.refreshToken!),
      ]);

      return creds;
    } catch (e) {
      FTAuth.error('Error refreshing tokens: $e');
      rethrow;
    }
  }
}
