import 'package:ftauth/ftauth.dart';
import 'package:ftauth/src/jwt/key.dart';

import 'crypto_repo.dart';

class CryptoRepoImpl extends CryptoRepo {
  CryptoRepoImpl([StorageRepo? storageRepo]);

  @override
  Future<List<int>> sign(List<int> block) {
    throw UnimplementedError();
  }

  @override
  Future<JsonWebKey> get publicKey => throw UnimplementedError();
}
