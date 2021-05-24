import 'dart:typed_data';

import 'package:ftauth_jwt/ftauth_jwt.dart';
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
      case Algorithm.RSASHA256:
        digest = SHA256Digest();
        break;
      case Algorithm.RSASHA384:
        digest = SHA384Digest();
        break;
      case Algorithm.RSASHA512:
        digest = SHA512Digest();
        break;
      default:
        throw UnsupportedError('Unsupported RSA algorithm: ${jwk.algorithm}');
    }
    return RsaPrivateKey(
      digest,
      pc.RSAPrivateKey(
        jwk.n!,
        jwk.d!,
        jwk.p!,
        jwk.q!,
      ),
    );
  }

  RsaPublicKey get publicKey {
    return RsaPublicKey(
      digest,
      pc.RSAPublicKey(
        _privateKey.modulus!,
        _privateKey.publicExponent!,
      ),
    );
  }

  @override
  Future<List<int>> sign(List<int> data) async {
    return _privateKey.sign(digest, data);
  }

  @override
  Future<void> verify(List<int> data, List<int> signature) async {
    return publicKey.verify(data, signature);
  }
}

class RsaPublicKey implements Verifier {
  final pc.Digest digest;
  final pc.RSAPublicKey _publicKey;

  RsaPublicKey(this.digest, this._publicKey);

  factory RsaPublicKey.fromJwk(JsonWebKey jwk) {
    pc.Digest digest;
    switch (jwk.algorithm) {
      case Algorithm.RSASHA256:
        digest = SHA256Digest();
        break;
      case Algorithm.RSASHA384:
        digest = SHA384Digest();
        break;
      case Algorithm.RSASHA512:
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
  Future<void> verify(List<int> data, List<int> signature) async {
    return _publicKey.verify(digest, data, signature);
  }
}

extension RSAVerifier on pc.RSAPublicKey {
  Future<void> verify(
    pc.Digest hash,
    List<int> data,
    List<int> signature,
  ) async {
    final signer = pc.Signer('${hash.algorithmName}/RSA');

    signer.init(false, pc.PublicKeyParameter<pc.RSAPublicKey>(this));

    final result = signer.verifySignature(
      Uint8List.fromList(data),
      pc.RSASignature(Uint8List.fromList(signature)),
    );

    if (!result) {
      throw const VerificationException();
    }
  }
}

extension RSASigner on pc.RSAPrivateKey {
  Future<List<int>> sign(
    pc.Digest digest,
    List<int> bytes,
  ) async {
    final signer = pc.Signer('${digest.algorithmName}/RSA');

    signer.init(true, pc.PrivateKeyParameter<pc.RSAPrivateKey>(this));
    final signature =
        signer.generateSignature(Uint8List.fromList(bytes)) as pc.RSASignature;
    return signature.bytes;
  }
}
