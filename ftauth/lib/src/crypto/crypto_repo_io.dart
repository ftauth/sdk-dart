import 'dart:io';

import 'package:crypto_keys/crypto_keys.dart';
import 'package:ftauth/src/jwt/key.dart';
import 'package:ftauth/src/storage/storage_repo.dart';

import 'crypto_repo.dart';

class CryptoRepoImpl extends CryptoRepo {
  Map<String, dynamic>? _privateKey;
  Map<String, dynamic>? _publicKey;

  CryptoRepoImpl([StorageRepo? storageRepo]) : super(storageRepo);

  @override
  Future<Map<String, dynamic>> generatePrivateKey() async {
    final findOpenSSL = await Process.run('which', ['openssl']);
    final openSSLAvailable = findOpenSSL.exitCode == 0;

    if (!openSSLAvailable) {
      throw ProcessException('which', ['openssl'], 'openssl binary not found.');
    }

    final genProc = await Process.run('openssl', ['genrsa', '2048']);
    if (genProc.exitCode != 0) {
      throw ProcessException('openssl', ['genrsa', '2048'], genProc.stderr);
    }

    final out = (genProc.stdout as String);
    const rsaHeader = '-----BEGIN RSA PRIVATE KEY-----';
    if (!out.contains(rsaHeader)) {
      throw ProcessException(
        'openssl',
        ['genrsa', '2048'],
        'Unknown output: ${genProc.stdout}',
      );
    }

    final pem = out.substring(out.indexOf(rsaHeader));
    final privateKey = JsonWebKey.fromPem(pem);
    return {};
  }

  @override
  Future<Map<String, dynamic>> generatePublicKey() {
    // TODO: implement generatePublicKey
    throw UnimplementedError();
  }
}
