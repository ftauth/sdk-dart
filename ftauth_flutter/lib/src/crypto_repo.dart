import 'package:ftauth/ftauth.dart';
import 'package:webcrypto/webcrypto.dart';

class FlutterCryptoRepo extends CryptoRepo {
  KeyPair<RsassaPkcs1V15PrivateKey, RsassaPkcs1V15PublicKey> _keyPair;

  @override
  Future<Map<String, dynamic>> generatePrivateKey() async {
    _keyPair = await RsassaPkcs1V15PrivateKey.generateKey(
      2048,
      BigInt.from(65537),
      Hash.sha256,
    );
    return _keyPair.privateKey.exportJsonWebKey();
  }

  @override
  Future<Map<String, dynamic>> generatePublicKey() async {
    return _keyPair.publicKey.exportJsonWebKey();
  }
}
