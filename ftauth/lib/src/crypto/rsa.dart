import 'package:ftauth/ftauth.dart';
import 'package:ftauth/src/jwt/alg.dart';
import 'package:ftauth/src/jwt/crypto.dart';
import 'package:cryptography/cryptography.dart' as crypto;
import 'package:ftauth/src/jwt/exception.dart';
import 'package:ftauth/src/jwt/key.dart';
import 'package:ftauth/src/jwt/util.dart';

class RsaPrivateKey extends PrivateKey {
  final crypto.SignatureAlgorithm alg;
  final crypto.RsaKeyPairData _data;

  RsaPrivateKey({
    required this.alg,
    required BigInt n,
    required BigInt e,
    required BigInt d,
    required BigInt p,
    required BigInt q,
    required BigInt dp,
    required BigInt dq,
    required BigInt qi,
  }) : _data = crypto.RsaKeyPairData(
          e: Base64UrlUintEncoder.encodeBigInt(e),
          n: Base64UrlUintEncoder.encodeBigInt(n),
          d: Base64UrlUintEncoder.encodeBigInt(d),
          p: Base64UrlUintEncoder.encodeBigInt(p),
          q: Base64UrlUintEncoder.encodeBigInt(q),
          dp: Base64UrlUintEncoder.encodeBigInt(dp),
          dq: Base64UrlUintEncoder.encodeBigInt(dq),
          qi: Base64UrlUintEncoder.encodeBigInt(qi),
        );

  factory RsaPrivateKey.fromJwk(JsonWebKey jwk) {
    if (!jwk.isPrivate) {
      throw ArgumentError('Invalid private RSA key');
    }
    crypto.SignatureAlgorithm alg;
    switch (jwk.algorithm) {
      case Algorithm.RSASHA256:
        alg = crypto.RsaSsaPkcs1v15(crypto.Sha256());
        break;
      case Algorithm.RSASHA384:
        alg = crypto.RsaSsaPkcs1v15(crypto.Sha384());
        break;
      case Algorithm.RSASHA512:
        alg = crypto.RsaSsaPkcs1v15(crypto.Sha512());
        break;
      case Algorithm.PSSSHA256:
        alg = crypto.RsaPss(crypto.Sha256());
        break;
      case Algorithm.PSSSHA384:
        alg = crypto.RsaPss(crypto.Sha384());
        break;
      case Algorithm.PSSSHA512:
        alg = crypto.RsaPss(crypto.Sha512());
        break;
      default:
        throw UnsupportedError('Invalid RSA algorithm: ${jwk.algorithm}');
    }
    return RsaPrivateKey(
      alg: alg,
      n: jwk.n!,
      e: jwk.e!,
      d: jwk.d!,
      p: jwk.p!,
      q: jwk.q!,
      dp: jwk.dp!,
      dq: jwk.dq!,
      qi: jwk.qi!,
    );
  }

  @override
  RsaPublicKey get publicKey => throw UnimplementedError();

  @override
  Future<List<int>> sign(List<int> bytes) async {
    final signature = await alg.sign(bytes, keyPair: _data);
    return signature.bytes;
  }

  @override
  Future<bool> verify(List<int> bytes, List<int> expected) async {
    return alg.verify(
      bytes,
      signature: crypto.Signature(
        expected,
        publicKey: await _data.extractPublicKey(),
      ),
    );
  }
}

class RsaPublicKey extends PublicKey {
  final crypto.SignatureAlgorithm alg;
  final crypto.RsaPublicKey _key;

  RsaPublicKey({
    required this.alg,
    required BigInt n,
    required BigInt e,
  }) : _key = crypto.RsaPublicKey(
          e: Base64UrlUintEncoder.encodeBigInt(e),
          n: Base64UrlUintEncoder.encodeBigInt(n),
        );

  factory RsaPublicKey.fromJwk(JsonWebKey jwk) {
    crypto.SignatureAlgorithm alg;
    switch (jwk.algorithm) {
      case Algorithm.RSASHA256:
        alg = crypto.RsaSsaPkcs1v15(crypto.Sha256());
        break;
      case Algorithm.RSASHA384:
        alg = crypto.RsaSsaPkcs1v15(crypto.Sha384());
        break;
      case Algorithm.RSASHA512:
        alg = crypto.RsaSsaPkcs1v15(crypto.Sha512());
        break;
      case Algorithm.PSSSHA256:
        alg = crypto.RsaPss(crypto.Sha256());
        break;
      case Algorithm.PSSSHA384:
        alg = crypto.RsaPss(crypto.Sha384());
        break;
      case Algorithm.PSSSHA512:
        alg = crypto.RsaPss(crypto.Sha512());
        break;
      default:
        throw UnsupportedError('Invalid RSA algorithm: ${jwk.algorithm}');
    }
    return RsaPublicKey(
      alg: alg,
      n: jwk.n!,
      e: jwk.e!,
    );
  }

  @override
  Future<void> verify(List<int> bytes, List<int> expected) async {
    if (!await alg.verify(
      bytes,
      signature: crypto.Signature(expected, publicKey: _key),
    )) {
      throw const InvalidSignatureException();
    }
  }
}
