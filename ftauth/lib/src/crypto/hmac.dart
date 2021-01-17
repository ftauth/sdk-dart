import 'package:crypto/crypto.dart';
import 'package:ftauth/src/jwt/crypto.dart';
import 'package:ftauth/src/jwt/exception.dart';

class HmacKey implements PrivateKey, PublicKey {
  final Hmac hmac;

  HmacKey(Hash hash, List<int> key) : hmac = Hmac(hash, key);

  @override
  PublicKey get publicKey => this;

  @override
  Future<List<int>> sign(List<int> bytes) async {
    return hmac.convert(bytes).bytes;
  }

  @override
  Future<void> verify(List<int> bytes, List<int> expected) async {
    final signed = hmac.convert(bytes);
    if (signed.bytes != expected) {
      throw const InvalidSignatureException();
    }
  }
}
