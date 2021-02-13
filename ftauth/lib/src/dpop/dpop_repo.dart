import 'package:ftauth/src/crypto/crypto_repo.dart';

import 'dpop_repo_impl.dart';

abstract class DPoPRepo {
  // TODO: Add generatePrivateKey methods to CryptoRepo
  // TODO: Load private key from storage every time we need it, instead
  // TODO: of storing it in memory.
  static final instance = DPoPRepoImpl(CryptoRepo.instance);

  Future<String> createProof(String httpMethod, Uri httpUri);
}
