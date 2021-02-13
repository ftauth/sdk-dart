import 'package:ftauth/src/jwt/key.dart';
import 'package:ftauth/src/storage/storage_repo.dart';

import '../crypto_repo.dart';
import 'crypto_subtle.dart';

class CryptoRepoImpl extends CryptoRepo {
  CryptoRepoImpl([StorageRepo? storageRepo]);

  @override
  Future<JsonWebKey?> get publicKey => throw UnimplementedError();

  @override
  Future<List<int>> sign(List<int> bytes) {
    throw UnimplementedError();
  }
}
