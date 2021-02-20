import 'package:crypto/crypto.dart';
import 'package:ftauth/src/jwt/crypto.dart';
import 'package:ftauth/src/jwt/exception.dart';

class HmacKey implements Signer, Verifier {
  final Hmac hmac;

  HmacKey(Hash hash, List<int> key) : hmac = Hmac(hash, key);

  @override
  Future<List<int>> sign(List<int> data) async {
    return hmac.convert(data).bytes;
  }

  @override
  Future<void> verify(List<int> data, List<int> signature) async {
    final signed = hmac.convert(data);
    if (signed.bytes != signature) {
      throw const VerificationException();
    }
  }
}
