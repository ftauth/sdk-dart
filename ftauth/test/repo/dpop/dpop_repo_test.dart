import 'package:ftauth/ftauth.dart';
import 'package:ftauth/src/dpop/dpop_repo_impl.dart';
import 'package:test/test.dart';

import '../../mock/storage_repo.dart';

void main() {
  final storageRepo = MockStorageRepo();
  final cryptoRepo = CryptoRepoImpl(storageRepo);
  final dpopRepo = DPoPRepoImpl(cryptoRepo);

  setUp(() async {
    await storageRepo.init();
  });

  group('DPoPRepo |', () {
    for (var i = 0; i < 100; i++) {
      test('sign and validate successfully $i', () async {
        final dpop = await dpopRepo.createToken(
          'GET',
          Uri.parse('http://localhost:8000'),
        );
        await dpop.encodeBase64(cryptoRepo);
        expect(
          cryptoRepo.verify(
            dpop.encodeUnsigned().codeUnits,
            dpop.signature,
          ),
          completes,
        );
      });
    }
  });
}
