import 'dart:convert';

import 'package:ftauth/src/storage/storage_repo.dart';
import 'crypto_repo_stub.dart';

export 'crypto_repo_stub.dart'
    if (dart.library.html) 'js/crypto_repo_js.dart'
    if (dart.library.io) 'crypto_repo_io.dart';

abstract class CryptoRepo {
  static CryptoRepo instance = CryptoRepoImpl();

  static const privateStorageKey = 'private_key';
  static const publicStorageKey = 'public_key';

  final StorageRepo _storageRepo;

  CryptoRepo([StorageRepo? storageRepo])
      : _storageRepo = storageRepo ?? StorageRepo.instance;

  Future<Map<String, dynamic>> generatePrivateKey();
  Future<Map<String, dynamic>> generatePublicKey();

  Future<Map<String, dynamic>> loadSigningKey() async {
    var json = await _storageRepo.getString(privateStorageKey);
    if (json != null) {
      return (jsonDecode(json) as Map).cast<String, dynamic>();
    }
    final privateKey = await generatePrivateKey();
    final publicKey = await generatePublicKey();
    await _storageRepo.setString(privateStorageKey, jsonEncode(privateKey));
    await _storageRepo.setString(publicStorageKey, jsonEncode(publicKey));
    return privateKey;
  }
}
