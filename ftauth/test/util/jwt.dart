import 'package:ftauth/ftauth.dart';
import 'package:ftauth_jwt/ftauth_jwt.dart';

import '../mock/mock_storage_repo.dart';

class JwtUtil {
  static final cryptoRepo = CryptoRepoImpl(MockStorageRepo());
  static JwtUtil? _instance;
  final JsonWebKey _privateKey;

  JwtUtil._(this._privateKey);

  static Future<JwtUtil> get instance async {
    if (_instance != null) {
      return _instance!;
    }
    final privateKey = await cryptoRepo.privateKey;
    return _instance ??= JwtUtil._(privateKey);
  }

  Future<String> createJWTToken({
    required DateTime expiration,
  }) {
    final jwt = JsonWebToken(
      header: JsonWebHeader(
        type: TokenType.JWT,
        algorithm: Algorithm.RSASHA256,
      ),
      claims: JsonWebClaims.fromJson(
        {
          'exp': expiration.millisecondsSinceEpoch ~/ 1000,
        },
      ),
    );

    return jwt.encodeBase64(_privateKey.signer);
  }
}
