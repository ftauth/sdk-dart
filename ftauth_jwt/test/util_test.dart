import 'package:ftauth_jwt/ftauth_jwt.dart';
import 'package:test/test.dart';

void main() {
  group('base64UrlUint', () {
    final bints = [BigInt.from(65537), BigInt.from(0), null];
    final encs = ['AQAB', 'AA', null];

    for (var i = 0; i < bints.length; i++) {
      test('encode ${bints[i].toString()}', () {
        final encoded = base64UrlUintEncode(bints[i]);
        expect(encoded, encs[i]);
      });

      test('decode ${bints[i].toString()}', () {
        final decoded = base64UrlUintTryDecode(encs[i]);
        expect(decoded, bints[i]);
      });
    }

    // Invalid inputs
    final inputs = ['Some non-base64 string', 'AA😂'];
    for (var i = 0; i < inputs.length; i++) {
      test('invalid input: "${inputs[i]}"', () {
        final decoded = base64UrlUintTryDecode(inputs[i]);
        expect(decoded, null);
      });
    }
  });
}
