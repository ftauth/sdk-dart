@Skip('Waiting on crypto impl')

import 'package:ftauth/src/crypto/crypto_repo.dart';
import 'package:test/test.dart';

import '../../mock/storage_repo.dart';

void main() {
  final storageRepo = MockStorageRepo();
  final cryptoRepo = CryptoRepoImpl();

  setUp(() async {
    await storageRepo.init();
  });

  group('CryptoRepo | ', () {});
}
