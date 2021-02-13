import 'dart:typed_data';

import 'package:ftauth/ftauth.dart';
import 'package:ftauth/src/jwt/alg.dart';
import 'package:ftauth/src/jwt/crypto.dart';
import 'package:ftauth/src/jwt/key.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/digests/sha384.dart';
import 'package:pointycastle/digests/sha512.dart';
import 'package:pointycastle/pointycastle.dart' as pc;

class RsaPrivateKey implements Signer, Verifier {
  final pc.Digest digest;
  final pc.RSAPrivateKey _privateKey;

  RsaPrivateKey(this.digest, this._privateKey);

  factory RsaPrivateKey.fromJwk(JsonWebKey jwk) {
    if (!jwk.isPrivate) {
      throw ArgumentError('Invalid private RSA key');
    }
    pc.Digest digest;
    switch (jwk.algorithm) {
      case Algorithm.PSSSHA256:
        digest = SHA256Digest();
        break;
      case Algorithm.PSSSHA384:
        digest = SHA384Digest();
        break;
      case Algorithm.PSSSHA512:
        digest = SHA512Digest();
        break;
      default:
        throw UnsupportedError('Unsupported RSA algorithm: ${jwk.algorithm}');
    }
    return RsaPrivateKey(
      digest,
      pc.RSAPrivateKey(
        jwk.e!,
        jwk.d!,
        jwk.p!,
        jwk.q!,
      ),
    );
  }

  pc.RSAPublicKey get publicKey {
    return pc.RSAPublicKey(_privateKey.modulus!, _privateKey.publicExponent!);
  }

  @override
  Future<List<int>> sign(List<int> bytes) async {
    return _privateKey.sign(digest, bytes);
  }

  @override
  Future<void> verify(List<int> bytes, List<int> expected) async {
    return publicKey.verify(bytes, expected);
  }
}

class RsaPublicKey implements Verifier {
  final pc.Digest digest;
  final pc.RSAPublicKey _publicKey;

  RsaPublicKey(this.digest, this._publicKey);

  factory RsaPublicKey.fromJwk(JsonWebKey jwk) {
    pc.Digest digest;
    switch (jwk.algorithm) {
      case Algorithm.PSSSHA256:
        digest = SHA256Digest();
        break;
      case Algorithm.PSSSHA384:
        digest = SHA384Digest();
        break;
      case Algorithm.PSSSHA512:
        digest = SHA512Digest();
        break;
      default:
        throw UnsupportedError('Unsupported RSA algorithm: ${jwk.algorithm}');
    }
    return RsaPublicKey(
      digest,
      pc.RSAPublicKey(jwk.n!, jwk.e!),
    );
  }

  @override
  Future<void> verify(List<int> bytes, List<int> expected) async {
    return _publicKey.verify(bytes, expected);
  }
}

extension RSAVerifier on pc.RSAPublicKey {
  Future<void> verify(List<int> bytes, List<int> expected) async {}
}

extension RSASigner on pc.RSAPrivateKey {
  Future<List<int>> sign(
    pc.Digest digest,
    List<int> bytes,
  ) async {
    final signer = pc.Signer('${digest.algorithmName}/PSS');

    signer.init(
      true,
      pc.ParametersWithSaltConfiguration(
        pc.PrivateKeyParameter<pc.RSAPrivateKey>(this),
        CryptoRepo.instance.secureRandom,
        20,
      ),
    );
    return (signer.generateSignature(Uint8List.fromList(bytes))
            as pc.PSSSignature)
        .bytes;
  }
}
