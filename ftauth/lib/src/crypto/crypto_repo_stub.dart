import 'package:ftauth/src/storage/storage_repo.dart';

import 'crypto_repo.dart';

class CryptoRepoImpl extends CryptoRepo {
  CryptoRepoImpl([StorageRepo? storageRepo]) : super(storageRepo);

  @override
  Future<Map<String, dynamic>> generatePrivateKey() {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> generatePublicKey() {
    throw UnimplementedError();
  }
}
