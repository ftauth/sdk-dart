import 'package:ftauth/src/crypto/crypto_repo.dart';
import 'package:test/test.dart';

import '../../mock/storage_repo.dart';

void main() {
  final storageRepo = MockStorageRepo();
  final cryptoRepo = CryptoRepoImpl(storageRepo);

  group('CryptoRepo | ', () {
    test('successfully generates and stores RSA key', () async {
      expect(storageRepo.getString(CryptoRepo.publicStorageKey), isNull);
      expect(storageRepo.getString(CryptoRepo.privateStorageKey), isNull);

      await cryptoRepo.loadSigningKey();

      final privateKey = storageRepo.getString(CryptoRepo.privateStorageKey);
      final publicKey = storageRepo.getString(CryptoRepo.publicStorageKey);
      expect(privateKey, isNotNull);
      expect(publicKey, isNotNull);

      await cryptoRepo.loadSigningKey();

      expect(storageRepo.getString(CryptoRepo.privateStorageKey), privateKey);
      expect(storageRepo.getString(CryptoRepo.publicStorageKey), publicKey);
    });
  });
}
