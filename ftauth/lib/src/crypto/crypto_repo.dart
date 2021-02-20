import 'dart:math';
import 'dart:typed_data';

import 'package:ftauth/src/jwt/crypto.dart';
import 'package:ftauth/src/jwt/key.dart';
import 'package:pointycastle/pointycastle.dart' as pc;
import 'package:pointycastle/random/fortuna_random.dart';

import 'crypto_repo_stub.dart'
    if (dart.library.html) 'js/crypto_repo_js.dart'
    if (dart.library.io) 'crypto_repo_io.dart'
    if (dart.library.js) 'crypto_repo_node.dart';

export 'crypto_repo_stub.dart'
    if (dart.library.html) 'js/crypto_repo_js.dart'
    if (dart.library.io) 'crypto_repo_io.dart'
    if (dart.library.js) 'crypto_repo_node.dart';

abstract class CryptoRepo implements Signer, Verifier {
  static CryptoRepo instance = CryptoRepoImpl();
  late final pc.SecureRandom secureRandom;

  CryptoRepo() {
    secureRandom = _initSecureRandom();
  }

  pc.SecureRandom _initSecureRandom() {
    final secureRandom = FortunaRandom();

    final seedSource = Random.secure();
    final seeds = <int>[];
    for (var i = 0; i < 32; i++) {
      seeds.add(seedSource.nextInt(255));
    }
    secureRandom.seed(pc.KeyParameter(Uint8List.fromList(seeds)));

    return secureRandom;
  }

  Future<JsonWebKey> get publicKey;
}
