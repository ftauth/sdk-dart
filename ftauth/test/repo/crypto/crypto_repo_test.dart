import 'package:ftauth/jwt.dart';
import 'package:ftauth/src/crypto/crypto_repo.dart';
import 'package:test/test.dart';

import '../../mock/storage_repo.dart';

void main() {
  final storageRepo = MockStorageRepo();
  final cryptoRepo = CryptoRepoImpl(storageRepo);
  final data = 'testing'.codeUnits;

  setUp(() async {
    await storageRepo.init();
  });

  group('CryptoRepo |', () {
    for (var i = 0; i < 1000; i++) {
      test('sign and verify successfully $i', () async {
        final signature = await cryptoRepo.sign(data);
        expect(cryptoRepo.verify(data, signature), completes);
      });
    }
  });
}
