import 'dart:convert';

import 'package:ftauth/src/storage/storage_repo.dart';
import 'package:webcrypto/webcrypto.dart';

abstract class CryptoRepo {
  static const privateStorageKey = 'private_key';
  static const publicStorageKey = 'public_key';

  Future<Map<String, dynamic>> loadSigningKey();
}

class CryptoRepoImpl extends CryptoRepo {
  final StorageRepo storageRepo;

  CryptoRepoImpl(this.storageRepo);

  @override
  Future<Map<String, dynamic>> loadSigningKey() async {
    var json = await storageRepo.getString(CryptoRepo.privateStorageKey);
    if (json != null) {
      return (jsonDecode(json) as Map).cast<String, dynamic>();
    }
    final key = await RsaPssPrivateKey.generateKey(
      2048,
      BigInt.from(65537),
      Hash.sha256,
    );
    final privateKey = await key.privateKey.exportJsonWebKey();
    final publicKey = await key.privateKey.exportJsonWebKey();
    await storageRepo.setString(
        CryptoRepo.privateStorageKey, jsonEncode(privateKey));
    await storageRepo.setString(
        CryptoRepo.publicStorageKey, jsonEncode(publicKey));
    return privateKey;
  }
}
