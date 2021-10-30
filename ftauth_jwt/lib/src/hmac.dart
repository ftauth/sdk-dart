import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:ftauth_jwt/ftauth_jwt.dart';
import 'package:pointycastle/export.dart' as pc;

class HmacKey implements Signer, Verifier {
  final pc.HMac hmac;

  HmacKey(pc.Digest hash, List<int> key)
      : hmac = pc.HMac.withDigest(hash)
          ..init(pc.KeyParameter(Uint8List.fromList(key)));

  factory HmacKey.fromJwk(JsonWebKey jwk) {
    pc.Digest digest;
    switch (jwk.algorithm) {
      case Algorithm.hmacSha256:
        digest = pc.SHA256Digest();
        break;
      case Algorithm.hmacSha384:
        digest = pc.SHA384Digest();
        break;
      case Algorithm.hmacSha512:
        digest = pc.SHA512Digest();
        break;
      default:
        throw UnsupportedError('Unsupported HMAC algorithm: ${jwk.algorithm}');
    }
    return HmacKey(digest, jwk.k!);
  }

  @override
  Future<List<int>> sign(List<int> data) async {
    return hmac.process(Uint8List.fromList(data));
  }

  @override
  Future<void> verify(List<int> data, List<int> signature) async {
    final signed = await sign(data);
    if (!const ListEquality().equals(signed, signature)) {
      throw const VerificationException();
    }
  }
}
