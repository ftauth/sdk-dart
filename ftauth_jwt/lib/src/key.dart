import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'alg.dart';
import 'elliptic_curve.dart';
import 'exception.dart';
import 'prefs.dart';
import 'key_type.dart';
import 'key_use.dart';
import 'key_ops.dart';
import 'util.dart';

part 'key.g.dart';

@serialize
@immutable
class JsonWebKey extends Equatable {
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
  Algorithm? get algorithm => _algorithm ?? _inferAlgorithm();

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

  JsonWebKey get publicKey {
    switch (keyType) {
      case KeyType.ellipticCurve:
        if (!isPrivate) {
          return this;
        }
        return JsonWebKey(
          keyType: keyType,
          publicKeyUse: publicKeyUse,
          algorithm: algorithm,
          keyId: keyId,
          x509Url: x509Url,
          x509CertChain: x509CertChain,
          x509Sha1Thumbprint: x509Sha1Thumbprint,
          x509Sha256Thumbprint: x509Sha256Thumbprint,
          x: x,
          y: y,
        );
      case KeyType.rsa:
        if (!isPrivate) {
          return this;
        }
        return JsonWebKey(
          keyType: keyType,
          publicKeyUse: publicKeyUse,
          algorithm: algorithm,
          keyId: keyId,
          x509Url: x509Url,
          x509CertChain: x509CertChain,
          x509Sha1Thumbprint: x509Sha1Thumbprint,
          x509Sha256Thumbprint: x509Sha256Thumbprint,
          n: n,
          e: e,
        );
      case KeyType.octet:
        return this;
    }
  }

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
  }

  Algorithm _inferAlgorithm() {
    switch (keyType) {
      case KeyType.ellipticCurve:
        if (ellipticCurve == null) {
          throw MissingParameterExeception('crv');
        }
        switch (ellipticCurve!) {
          case EllipticCurve.p256:
            return Algorithm.ecdsaSha256;
          case EllipticCurve.p384:
            return Algorithm.ecdsaSha384;
          case EllipticCurve.p521:
            return Algorithm.ecdsaSha512;
        }
      case KeyType.rsa:
        return Algorithm.rsaSha256;
      case KeyType.octet:
        return Algorithm.hmacSha256;
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
    if (_algorithm == null) {
      map.remove('alg');
    }
    return map;
  }

  bool _hasPrivateKeyInfo() {
    switch (keyType) {
      case KeyType.ellipticCurve:
        return d != null;
      case KeyType.rsa:
        return d != null;
      case KeyType.octet:
        return true;
    }
  }

  void assertValid() {
    switch (keyType) {
      case KeyType.ellipticCurve:
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
      case KeyType.rsa:
        if (n == null) {
          throw MissingParameterExeception('n');
        }
        if (e == null) {
          throw MissingParameterExeception('e');
        }
        break;
      case KeyType.octet:
        if (k == null) {
          throw MissingParameterExeception('k');
        }
    }
  }
}

@serialize
class OtherPrime extends Equatable {
  @JsonKey(fromJson: base64UrlUintDecode, toJson: base64UrlUintEncode)
  final BigInt r;

  @JsonKey(fromJson: base64UrlUintDecode, toJson: base64UrlUintEncode)
  final BigInt d;

  @JsonKey(fromJson: base64UrlUintDecode, toJson: base64UrlUintEncode)
  final BigInt t;

  OtherPrime({
    required this.r,
    required this.d,
    required this.t,
  });

  @override
  List<Object?> get props => [r, d, t];

  factory OtherPrime.fromJson(Map<String, dynamic> json) =>
      _$OtherPrimeFromJson(json);

  Map<String, dynamic> toJson() => _$OtherPrimeToJson(this);
}
