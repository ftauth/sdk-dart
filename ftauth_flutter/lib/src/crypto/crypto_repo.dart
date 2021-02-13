import 'package:ftauth/ftauth.dart';
import 'package:ftauth/jwt.dart';
import 'package:webcrypto/webcrypto.dart';

class FlutterCryptoRepo extends CryptoRepo {
  KeyPair<RsaPssPrivateKey, RsaPssPublicKey>? _keyPair;

  Future<Map<String, dynamic>> _generatePrivateKey() async {
    _keyPair ??= await RsaPssPrivateKey.generateKey(
      2048,
      BigInt.from(65537),
      Hash.sha256,
    );
    return _keyPair!.privateKey.exportJsonWebKey();
  }

  Future<Map<String, dynamic>> _generatePublicKey() async {
    if (_keyPair == null) {
      _generatePrivateKey();
    }
    return _keyPair!.publicKey.exportJsonWebKey();
  }

  @override
  Future<JsonWebKey> get publicKey async =>
      JsonWebKey.fromJson(await _generatePublicKey());

  @override
  Future<List<int>> sign(List<int> bytes) {
    if (_keyPair == null) {
      _generatePrivateKey();
    }
    return _keyPair!.privateKey.signBytes(bytes, 20);
  }
}
