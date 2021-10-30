import 'dart:typed_data';

import 'package:ftauth_jwt/ftauth_jwt.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/digests/sha384.dart';
import 'package:pointycastle/digests/sha512.dart';
import 'package:pointycastle/ecc/curves/secp256r1.dart';
import 'package:pointycastle/ecc/curves/secp384r1.dart';
import 'package:pointycastle/ecc/curves/secp521r1.dart';
import 'package:pointycastle/pointycastle.dart' as pc;
// ignore: implementation_imports
import 'package:pointycastle/src/utils.dart';

class EcdsaPrivateKey implements Signer, Verifier {
  final pc.Digest digest;
  final pc.ECPrivateKey _privateKey;
  final pc.ECPublicKey _publicKey;

  EcdsaPrivateKey(
    this.digest,
    this._privateKey,
    this._publicKey,
  );

  factory EcdsaPrivateKey.fromJwk(JsonWebKey jwk) {
    if (!jwk.isPrivate) {
      throw ArgumentError('Invalid private ECDSA key');
    }
    pc.Digest digest;
    pc.ECDomainParameters params;
    switch (jwk.algorithm) {
      case Algorithm.ecdsaSha256:
        digest = SHA256Digest();
        params = ECCurve_secp256r1();
        break;
      case Algorithm.ecdsaSha384:
        digest = SHA384Digest();
        params = ECCurve_secp384r1();
        break;
      case Algorithm.ecdsaSha512:
        digest = SHA512Digest();
        params = ECCurve_secp521r1();
        break;
      default:
        throw UnsupportedError('Unsupported ECDSA algorithm: ${jwk.algorithm}');
    }
    final q = params.curve.createPoint(jwk.x!, jwk.y!);
    return EcdsaPrivateKey(
      digest,
      pc.ECPrivateKey(jwk.d!, params),
      pc.ECPublicKey(q, params),
    );
  }

  EcdsaPublicKey get publicKey {
    return EcdsaPublicKey(digest, _publicKey);
  }

  @override
  Future<List<int>> sign(List<int> data) {
    return _privateKey.sign(digest, data);
  }

  @override
  Future<void> verify(List<int> data, List<int> signature) {
    return publicKey.verify(data, signature);
  }
}

class EcdsaPublicKey implements Verifier {
  final pc.Digest digest;
  final pc.ECPublicKey _publicKey;

  EcdsaPublicKey(this.digest, this._publicKey);

  factory EcdsaPublicKey.fromJwk(JsonWebKey jwk) {
    pc.Digest digest;
    pc.ECDomainParameters params;
    switch (jwk.algorithm) {
      case Algorithm.ecdsaSha256:
        digest = SHA256Digest();
        params = ECCurve_secp256r1();
        break;
      case Algorithm.ecdsaSha384:
        digest = SHA384Digest();
        params = ECCurve_secp384r1();
        break;
      case Algorithm.ecdsaSha512:
        digest = SHA512Digest();
        params = ECCurve_secp521r1();
        break;
      default:
        throw UnsupportedError('Unsupported ECDSA algorithm: ${jwk.algorithm}');
    }
    final q = params.curve.createPoint(jwk.x!, jwk.y!);
    return EcdsaPublicKey(
      digest,
      pc.ECPublicKey(q, params),
    );
  }

  @override
  Future<void> verify(List<int> data, List<int> signature) {
    return _publicKey.verify(digest, data, signature);
  }
}

extension on pc.ECPublicKey {
  Future<void> verify(
    pc.Digest hash,
    List<int> data,
    List<int> signature,
  ) async {
    final signer = pc.Signer('${hash.algorithmName}/ECDSA');

    signer.init(false, pc.PublicKeyParameter<pc.ECPublicKey>(this));

    final seqLength = signature.length ~/ 2;
    final r = decodeBigIntWithSign(1, signature.sublist(0, seqLength));
    final s = decodeBigIntWithSign(1, signature.sublist(seqLength));
    final result = signer.verifySignature(
      Uint8List.fromList(data),
      pc.ECSignature(r, s),
    );

    if (!result) {
      throw const VerificationException();
    }
  }
}

extension on pc.ECPrivateKey {
  Future<List<int>> sign(
    pc.Digest digest,
    List<int> bytes,
  ) async {
    final signer = pc.Signer('${digest.algorithmName}/ECDSA');

    signer.init(
      true,
      pc.ParametersWithRandom(
        pc.PrivateKeyParameter<pc.ECPrivateKey>(this),
        initSecureRandom(),
      ),
    );

    final signature =
        signer.generateSignature(Uint8List.fromList(bytes)) as pc.ECSignature;
    final r = encodeBigIntAsUnsigned(signature.r);
    final s = encodeBigIntAsUnsigned(signature.s);
    return [...r, ...s];
  }
}
