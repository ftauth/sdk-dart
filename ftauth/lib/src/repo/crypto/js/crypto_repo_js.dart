import 'dart:convert';
import 'dart:typed_data';
import 'package:ftauth/ftauth.dart';
import 'package:ftauth/src/authorizer/keys.dart';
import 'package:ftauth_jwt/ftauth_jwt.dart';
import 'package:js/js_util.dart';

import 'crypto_subtle.dart' as subtle;

class CryptoRepoImpl extends CryptoRepo {
  CryptoRepoImpl([StorageRepo? storageRepo])
      : _storageRepo = storageRepo ?? StorageRepo.instance;

  final StorageRepo _storageRepo;
  subtle.CryptoKeyPair? _keyPair;

  Future<subtle.CryptoKeyPair> _generateKeyPair() async {
    if (_keyPair != null) {
      return _keyPair!;
    }

    final params = subtle.RsaHashedKeyGenParams(
      name: 'RSASSA-PKCS1-v1_5',
      modulusLength: 2048,
      publicExponent: Uint8List.fromList([1, 0, 1]), // 65537
      hash: 'SHA-256',
    );

    // Check if there is a key in storage
    final key = await _storageRepo.getString(keyPrivateKey);
    if (key != null) {
      final jwk = jsify(jsonDecode(key));
      final promise =
          subtle.importKey('jwk', jwk, params, false, ['sign', 'verify']);
      return _keyPair = await promiseToFuture<subtle.CryptoKeyPair>(promise);
    }

    // Generate the key if there's none
    final promise = subtle.generateKey(params, true, ['sign', 'verify']);
    _keyPair = await promiseToFuture<subtle.CryptoKeyPair>(promise);

    // Save the key to storage
    final jsJwkPromise = subtle.exportKey('jwk', _keyPair!.privateKey);
    final jsJwk = await promiseToFuture<Object>(jsJwkPromise);
    final jwk = subtle.stringify(jsJwk);
    await _storageRepo.setString(keyPrivateKey, jwk);

    return _keyPair!;
  }

  Future<JsonWebKey> _cryptoKeyToJWK(subtle.CryptoKey key) async {
    final jsJwkPromise = subtle.exportKey('jwk', key);
    final jsJwk = await promiseToFuture<Object>(jsJwkPromise);
    final jwk = subtle.stringify(jsJwk);
    return JsonWebKey.fromJson(jsonDecode(jwk));
  }

  @override
  Future<List<int>> sign(List<int> data) async {
    final keyPair = await _generateKeyPair();

    final promise = subtle.sign(
      'RSASSA-PKCS1-v1_5',
      keyPair.privateKey,
      Uint8List.fromList(data),
    );
    final signature = await promiseToFuture<ByteBuffer>(promise);

    return signature.asUint8List();
  }

  @override
  Future<JsonWebKey> get publicKey async {
    final keyPair = await _generateKeyPair();
    return _cryptoKeyToJWK(keyPair.publicKey);
  }

  @override
  Future<JsonWebKey> get privateKey async {
    final keyPair = await _generateKeyPair();
    return _cryptoKeyToJWK(keyPair.privateKey);
  }

  @override
  Future<void> verify(List<int> data, List<int> signature) async {
    final keyPair = await _generateKeyPair();
    final promise = subtle.verify(
      'RSASSA-PKCS1-v1_5',
      keyPair.publicKey,
      Uint8List.fromList(signature),
      Uint8List.fromList(data),
    );
    final result = await promiseToFuture<bool>(promise);
    if (!result) {
      throw const VerificationException();
    }
  }
}
