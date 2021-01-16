import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';
import 'package:ftauth/src/jwt/exception.dart';
import 'package:ftauth/src/jwt/token.dart';
import 'package:ftauth/src/jwt/util.dart';
import 'package:json_annotation/json_annotation.dart';

import 'alg.dart';
import 'ecdsa.dart';
import 'prefs.dart';
import 'key_type.dart';
import 'key_use.dart';
import 'key_ops.dart';
import 'rsa.dart';
import 'signer.dart';
import 'verifier.dart';

part 'key.g.dart';

@serialize
class JsonWebKey extends Equatable implements Signer, Verifier {
  @JsonKey(ignore: true)
  late final bool isPrivate;

  @JsonKey(name: 'kty', toJson: KeyTypeX.toJson, fromJson: KeyTypeX.fromJson)
  final KeyType keyType;

  @JsonKey(
    name: 'use',
    toJson: PublicKeyUseX.toJson,
    fromJson: PublicKeyUseX.fromJson,
  )
  final PublicKeyUse? publicKeyUse;

  @JsonKey(name: 'key_ops')
  final List<KeyOperation>? keyOperations;

  final Algorithm? _algorithm;

  @JsonKey(
    name: 'alg',
    fromJson: AlgorithmX.tryFromJson,
    toJson: AlgorithmX.toJson,
  )
  Algorithm get algorithm {
    return _algorithm ?? _inferAlgorithm();
  }

  @JsonKey(name: 'kid')
  final String? keyId;

  @JsonKey(name: 'x5u')
  final String? x509Url;

  @JsonKey(name: 'x5c')
  final List<String>? x509CertChain;

  @JsonKey(name: 'x5t')
  final String? x509Sha1Thumbprint;

  @JsonKey(name: 'x5t#S256')
  final String? x509Sha256Thumbprint;

  @JsonKey(
    name: 'crv',
    fromJson: EllipticCurveX.fromJson,
    toJson: EllipticCurveX.toJson,
  )
  final EllipticCurve? ellipticCurve;

  @JsonKey(fromJson: base64UrlUintTryDecode, toJson: base64UrlUintEncode)
  final BigInt? x;

  @JsonKey(fromJson: base64UrlUintTryDecode, toJson: base64UrlUintEncode)
  final BigInt? y;

  @JsonKey(fromJson: base64UrlUintTryDecode, toJson: base64UrlUintEncode)
  final BigInt? n;

  @JsonKey(fromJson: base64UrlUintTryDecode, toJson: base64UrlUintEncode)
  final BigInt? e;

  @JsonKey(fromJson: symmetricKeyFromJson, toJson: symmetricKeyToJson)
  final List<int>? k;

  @JsonKey(fromJson: base64UrlUintTryDecode, toJson: base64UrlUintEncode)
  final BigInt? d;

  @JsonKey(fromJson: base64UrlUintTryDecode, toJson: base64UrlUintEncode)
  final BigInt? p;

  @JsonKey(fromJson: base64UrlUintTryDecode, toJson: base64UrlUintEncode)
  final BigInt? q;

  @JsonKey(fromJson: base64UrlUintTryDecode, toJson: base64UrlUintEncode)
  final BigInt? dp;

  @JsonKey(fromJson: base64UrlUintTryDecode, toJson: base64UrlUintEncode)
  final BigInt? dq;

  @JsonKey(fromJson: base64UrlUintTryDecode, toJson: base64UrlUintEncode)
  final BigInt? qi;

  @JsonKey(name: 'oth')
  final List<OtherPrime>? otherPrimes;

  late final Verifier? _verifier;
  late final Signer? _signer;

  JsonWebKey({
    required this.keyType,
    this.publicKeyUse,
    this.keyOperations,
    Algorithm? algorithm,
    this.keyId,
    this.x509Url,
    this.x509CertChain,
    this.x509Sha1Thumbprint,
    this.x509Sha256Thumbprint,
    this.ellipticCurve,
    this.x,
    this.y,
    this.n,
    this.e,
    this.k,
    this.d,
    this.p,
    this.q,
    this.dp,
    this.dq,
    this.qi,
    this.otherPrimes,
  }) : _algorithm = algorithm {
    isPrivate = _hasPrivateKeyInfo();
    assertValid();
    _verifier = _createVerifier();
    if (isPrivate) {
      _signer = _createSigner();
    }
  }

  Algorithm _inferAlgorithm() {
    switch (keyType) {
      case KeyType.EllipticCurve:
        if (ellipticCurve == null) {
          throw MissingParameterExeception('crv');
        }
        switch (ellipticCurve!) {
          case EllipticCurve.P256:
            return Algorithm.ECDSASHA256;
          case EllipticCurve.P384:
            return Algorithm.ECDSASHA384;
          case EllipticCurve.P521:
            return Algorithm.ECDSASHA512;
        }
      case KeyType.RSA:
        return Algorithm.RSASHA256;
      case KeyType.Octet:
        return Algorithm.HMACSHA256;
    }
  }

  @override
  List<Object?> get props => [
        keyType,
        publicKeyUse,
        keyOperations,
        algorithm,
        keyId,
        x509Url,
        x509CertChain,
        x509Sha1Thumbprint,
        x509Sha256Thumbprint,
        ellipticCurve,
        x,
        y,
        n,
        e,
        k,
        d,
        p,
        q,
        dp,
        dq,
        qi,
        otherPrimes,
      ];

  factory JsonWebKey.fromJson(Map<String, dynamic> json) =>
      _$JsonWebKeyFromJson(json);

  Map<String, dynamic> toJson() {
    final map = _$JsonWebKeyToJson(this);

    // Strip if not included originally.
    if (_algorithm == null && map.containsKey('alg')) {
      map.remove('alg');
    }
    return map;
  }

  bool _hasPrivateKeyInfo() {
    switch (keyType) {
      case KeyType.EllipticCurve:
        return d != null;
      case KeyType.RSA:
        return d != null &&
            p != null &&
            q != null &&
            dp != null &&
            dq != null &&
            qi != null;
      case KeyType.Octet:
        return true;
    }
  }

  void assertValid() {
    switch (keyType) {
      case KeyType.EllipticCurve:
        if (ellipticCurve == null) {
          throw MissingParameterExeception('crv');
        }
        if (x == null) {
          throw MissingParameterExeception('x');
        }
        if (y == null) {
          throw MissingParameterExeception('y');
        }
        break;
      case KeyType.RSA:
        if (n == null) {
          throw MissingParameterExeception('n');
        }
        if (e == null) {
          throw MissingParameterExeception('e');
        }
        break;
      case KeyType.Octet:
        if (k == null) {
          throw MissingParameterExeception('k');
        }
    }
  }

  @override
  List<int> sign(List<int> bytes) {
    if (!isPrivate || _signer == null) {
      throw StateError('No private key information included.');
    }

    return _signer!.sign(bytes);
  }

  @override
  void verify(JsonWebToken token) {
    _verifier?.verify(token);
  }

  Verifier? _createVerifier() {
    switch (algorithm) {
      case Algorithm.HMACSHA256:
        return _HmacVerifier(sha256, k!);
      case Algorithm.HMACSHA384:
        return _HmacVerifier(sha384, k!);
      case Algorithm.HMACSHA512:
        return _HmacVerifier(sha512, k!);
      default:
        // TODO: Uncomment
        // throw UnsupportedError('Unsupported algorithm: $algorithm');
        break;
    }
  }

  Signer? _createSigner() {
    switch (algorithm) {
      case Algorithm.HMACSHA256:
        return _HmacSigner(sha256, k!);
      case Algorithm.HMACSHA384:
        return _HmacSigner(sha384, k!);
      case Algorithm.HMACSHA512:
        return _HmacSigner(sha512, k!);
      default:
        // TODO: Uncomment
        // throw UnsupportedError('Unsupported algorithm: $algorithm');
        break;
    }
  }
}

class _HmacVerifier extends Verifier {
  final Hmac hmac;

  _HmacVerifier(Hash hash, List<int> key) : hmac = Hmac(hash, key);

  @override
  void verify(JsonWebToken token) {
    final signed = hmac.convert(token.encodeUnsigned().codeUnits);
    final signature = token.signature;
    if (signed.bytes != signature) {
      throw const VerificationException();
    }
  }
}

class _HmacSigner extends Signer {
  final Hmac hmac;

  _HmacSigner(Hash hash, List<int> key) : hmac = Hmac(hash, key);

  @override
  List<int> sign(List<int> bytes) {
    return hmac.convert(bytes).bytes;
  }
}
