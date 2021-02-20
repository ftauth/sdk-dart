import 'dart:typed_data';

import 'package:ftauth/ftauth.dart';
import 'package:ftauth/jwt.dart';
import 'package:ftauth/src/jwt/alg.dart';
import 'package:ftauth/src/jwt/crypto.dart';
import 'package:ftauth/src/jwt/key.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/digests/sha384.dart';
import 'package:pointycastle/digests/sha512.dart';
import 'package:pointycastle/pointycastle.dart' as pc;
import 'package:pointycastle/src/utils.dart';

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
  Future<List<int>> sign(List<int> data) async {
    return _privateKey.sign(digest, data);
  }

  @override
  Future<void> verify(List<int> data, List<int> signature) async {
    return publicKey.verify(digest, data, signature);
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
  Future<void> verify(List<int> data, List<int> signature) async {
    return _publicKey.verify(digest, data, signature);
  }
}

extension SaltLength on pc.RSAAsymmetricKey {
  /// Salt length is set to the maximum size.
  int saltLength(pc.Digest hash) {
    return keySize - 2 - hash.digestSize;
  }

  /// Returns the modulus size in bytes.
  int get keySize {
    return (modulus!.bitLength + 7) ~/ 8;
  }
}

class PSSSaltMiner {
  final pc.RSAPublicKey publicKey;
  final pc.Digest hash;

  const PSSSaltMiner(this.publicKey, this.hash);

  BigInt _encrypt(BigInt m) {
    return m.modPow(publicKey.publicExponent!, publicKey.modulus!);
  }

  void _incCounter(Uint8List c) {
    c[3]++;
    if (c[3] != 0) {
      return;
    }
    c[2]++;
    if (c[2] != 0) {
      return;
    }
    c[1]++;
    if (c[1] != 0) {
      return;
    }
    c[0]++;
  }

  void mgf1XOR(Uint8List out, pc.Digest hash, Uint8List seed) {
    final counter = Uint8List(4);
    Uint8List digest;

    var done = 0;
    while (done < out.lengthInBytes) {
      hash.update(seed, 0, seed.lengthInBytes);
      hash.update(counter, 0, 4);

      digest = Uint8List(hash.digestSize);
      hash.doFinal(digest, 0);
      hash.reset();

      for (var i = 0; i < digest.length && done < out.lengthInBytes; i++) {
        out[done] ^= digest[i];
        done++;
      }
      _incCounter(counter);
    }
  }

  Uint8List saltFromSignature(Uint8List digest, Uint8List signature) {
    // Extract salt from signature.
    // See RFC 8017, Section 9.1.2

    final s = decodeBigIntWithSign(1, signature);
    final m = _encrypt(s);
    final emBits = publicKey.modulus!.bitLength - 1;
    final emLen = (emBits + 7) ~/ 8;
    final em = Uint8List(emLen);
    final emRaw = encodeBigIntAsUnsigned(m.abs());
    em.setAll(emLen - emRaw.length, emRaw);

    final hLen = hash.digestSize;
    final sLen = publicKey.saltLength(hash);

    // 1.  If the length of M is greater than the input limitation for the
    //     hash function (2^61 - 1 octets for SHA-1), output "inconsistent"
    //     and stop.
    //
    // 2.  Let mHash = Hash(M), an octet string of length hLen.
    if (hLen != digest.lengthInBytes) {
      throw const VerificationException();
    }

    // 3.  If emLen < hLen + sLen + 2, output "inconsistent" and stop.
    if (emLen < hLen + sLen + 2) {
      throw const VerificationException();
    }

    // 4.  If the rightmost octet of EM does not have hexadecimal value
    //     0xbc, output "inconsistent" and stop.
    if (em.last != 0xbc) {
      throw const VerificationException();
    }

    // 5.  Let maskedDB be the leftmost emLen - hLen - 1 octets of EM, and
    //     let H be the next hLen octets.
    final db = em.sublist(0, emLen - hLen - 1);
    final h = em.sublist(emLen - hLen - 1, emLen - 1);

    // 6.  If the leftmost 8 * emLen - emBits bits of the leftmost octet in
    //     maskedDB are not all equal to zero, output "inconsistent" and
    //     stop.
    final bitMask = 0xff >> (8 * emLen - emBits);
    if (em[0] & ~bitMask != 0) {
      throw const VerificationException();
    }

    // 7.  Let dbMask = MGF(H, emLen - hLen - 1).
    //
    // 8.  Let DB = maskedDB \xor dbMask.
    mgf1XOR(db, hash, h);

    // 9.  Set the leftmost 8 * emLen - emBits bits of the leftmost octet in DB
    //     to zero.
    db[0] &= bitMask;

    // 10. If the emLen - hLen - sLen - 2 leftmost octets of DB are not zero
    //     or if the octet at position emLen - hLen - sLen - 1 (the leftmost
    //     position is "position 1") does not have hexadecimal value 0x01,
    //     output "inconsistent" and stop.
    final psLen = emLen - hLen - sLen - 2;
    for (var e in db.sublist(0, psLen)) {
      if (e != 0x00) {
        throw const VerificationException();
      }
    }
    if (db[psLen] != 0x01) {
      throw const VerificationException();
    }

    // 11.  Let salt be the last sLen octets of DB.
    final salt = db.sublist(db.length - sLen);

    return salt;
  }
}

extension RSAVerifier on pc.RSAPublicKey {
  Future<void> verify(
    pc.Digest hash,
    List<int> data,
    List<int> signature,
  ) async {
    final digest = hash.process(Uint8List.fromList(data));
    final salt = PSSSaltMiner(this, hash).saltFromSignature(
      digest,
      Uint8List.fromList(signature),
    );
    final signer = pc.Signer('${hash.algorithmName}/PSS');

    signer.init(
      false,
      pc.ParametersWithSalt(
        pc.PublicKeyParameter<pc.RSAPublicKey>(this),
        salt,
      ),
    );

    final result = signer.verifySignature(
      Uint8List.fromList(data),
      pc.PSSSignature(Uint8List.fromList(signature)),
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
    final signer = pc.Signer('${digest.algorithmName}/PSS');

    signer.init(
      true,
      pc.ParametersWithSaltConfiguration(
        pc.PrivateKeyParameter<pc.RSAPrivateKey>(this),
        CryptoRepo.instance.secureRandom,
        saltLength(digest),
      ),
    );
    final signature =
        signer.generateSignature(Uint8List.fromList(bytes)) as pc.PSSSignature;
    return signature.bytes;
  }
}
