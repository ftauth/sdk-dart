import 'package:ftauth/ftauth.dart';
import 'package:ftauth_jwt/ftauth_jwt.dart';

import 'dpop_repo_impl.dart';

abstract class DPoPRepo {
  static late final instance = DPoPRepoImpl(CryptoRepo.instance);

  factory DPoPRepo() {
    return instance;
  }

  Future<String> createProof(String httpMethod, Uri httpUri);
  Future<JsonWebToken> createToken(String httpMethod, Uri httpUri);
}
