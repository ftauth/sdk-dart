import 'package:ftauth/src/storage/storage_repo.dart';

import '../crypto_repo.dart';
import 'crypto_subtle.dart';

class CryptoRepoImpl extends CryptoRepo {
  Map<String, dynamic>? _privateKey;
  Map<String, dynamic>? _publicKey;

  CryptoRepoImpl([StorageRepo? storageRepo]) : super(storageRepo);

  @override
  Future<Map<String, dynamic>> generatePrivateKey() async {
    if (_privateKey != null) {
      return _privateKey!;
    }
    final keyPair = await promiseAsFuture(generateKeyPair(
      Algorithm(name: 'RSA-PSS'),
      true,
      ['sign', 'verify'],
    ));
    _privateKey =
        jsonWebKeyFromJs(exportKey('jwk', keyPair.privateKey)).toJson();
    _publicKey = jsonWebKeyFromJs(exportKey('jwk', keyPair.publicKey)).toJson();

    return _privateKey!;
  }

  @override
  Future<Map<String, dynamic>> generatePublicKey() async {
    if (_publicKey == null) {
      await generatePrivateKey();
    }
    return _publicKey!;
  }
}
