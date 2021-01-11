import 'package:ftauth/src/crypto/crypto_repo.dart';

import 'dpop_repo_impl.dart';

abstract class DPoPRepo {
  static final instance = DPoPRepoImpl(CryptoRepo.instance);

  Future<String> createProof(String httpMethod, Uri httpUri);
}
