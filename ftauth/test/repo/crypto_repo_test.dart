import 'package:ftauth/src/crypto/crypto_repo.dart';
import 'package:ftauth/src/storage/storage_repo.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class FakeStorageRepo extends Fake implements StorageRepo {
  final memCache = <String, String>{};

  @override
  Future<void> setString(String key, String value) async {
    memCache[key] = value;
  }

  @override
  String? getString(String key) {
    return memCache[key];
  }

  @override
  Future<void> deleteKey(String key) async {
    memCache.remove(key);
  }
}

void main() {
  final storageRepo = FakeStorageRepo();
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
