import 'dart:convert';

import 'package:ftauth/ftauth.dart';
import 'package:ftauth/src/authorizer/keys.dart';
import 'package:ftauth_jwt/ftauth_jwt.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/pointycastle.dart' hide Algorithm;
import 'package:uuid/uuid.dart';

class CryptoRepoImpl extends CryptoRepo {
  final StorageRepo _storageRepo;

  CryptoRepoImpl([StorageRepo? storageRepo])
      : _storageRepo = storageRepo ?? StorageRepo.instance;

  Future<RSAPrivateKey> _generatePrivateKey({int bitLength = 2048}) async {
    final keyGen = RSAKeyGenerator()
      ..init(ParametersWithRandom(
          RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
          secureRandom));

    final pair = keyGen.generateKeyPair();
    final privateKey = pair.privateKey as RSAPrivateKey;
    await _savePrivateKey(privateKey);
    return privateKey;
  }

  Future<JsonWebKey> _savePrivateKey(RSAPrivateKey privateKey) async {
    final privateJWK = JsonWebKey(
      keyType: KeyType.RSA,
      algorithm: Algorithm.RSASHA256,
      publicKeyUse: PublicKeyUse.signature,
      keyId: Uuid().v4(),
      n: privateKey.n,
      e: privateKey.publicExponent,
      d: privateKey.privateExponent,
      p: privateKey.p,
      q: privateKey.q,
    );
    await _storageRepo.setString(
      keyPrivateKey,
      jsonEncode(privateJWK.toJson()),
    );
    return privateJWK;
  }

  Future<JsonWebKey> _loadJWK() async {
    var json = await _storageRepo.getString(keyPrivateKey);
    if (json == null) {
      await _generatePrivateKey();
    }
    json = await _storageRepo.getString(keyPrivateKey);
    return JsonWebKey.fromJson(
      (jsonDecode(json!) as Map).cast<String, dynamic>(),
    );
  }

  Future<RSAPrivateKey> _loadSigningKey() async {
    var json = await _storageRepo.getString(keyPrivateKey);
    if (json != null) {
      final jwk = JsonWebKey.fromJson(
        (jsonDecode(json) as Map).cast<String, dynamic>(),
      );
      return RSAPrivateKey(
        jwk.n!,
        jwk.d!,
        jwk.p!,
        jwk.q!,
      );
    }
    final privateKey = await _generatePrivateKey();
    return privateKey;
  }

  @override
  Future<List<int>> sign(List<int> block) async {
    final privateKey = await _loadSigningKey();
    return privateKey.sign(SHA256Digest(), block);
  }

  @override
  Future<JsonWebKey> get publicKey async {
    final privateJWK = await _loadJWK();
    return privateJWK.publicKey;
  }

  @override
  Future<JsonWebKey> get privateKey => _loadJWK();

  @override
  Future<void> verify(List<int> data, List<int> signature) async {
    final privateKey = await _loadSigningKey();
    return RsaPrivateKey(SHA256Digest(), privateKey).verify(data, signature);
  }
}
