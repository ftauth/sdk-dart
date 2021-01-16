import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'alg.dart';
import 'key.dart';
import 'type.dart';
import 'exception.dart';
import 'prefs.dart';
import 'util.dart';

part 'header.g.dart';

@serialize
class JsonWebHeader extends Equatable {
  @JsonKey(
      name: 'typ', fromJson: TokenTypeX.fromJson, toJson: TokenTypeX.toJson)
  final TokenType type;

  @JsonKey(name: 'cty')
  final String? contentType;

  @JsonKey(
      name: 'alg', fromJson: AlgorithmX.fromJson, toJson: AlgorithmX.toJson)
  final Algorithm algorithm;

  @JsonKey(name: 'jwu')
  final Uri? jwkSetUri;

  @JsonKey(name: 'jwk')
  final JsonWebKey? jwk;

  @JsonKey(name: 'kid')
  final String? keyId;

  @JsonKey(name: 'x5u')
  final Uri? x509Uri;

  @JsonKey(name: 'x5c')
  final List<String>? x509CertChain;

  @JsonKey(name: 'x5t')
  final String? x509sha1Thumbprint;

  @JsonKey(name: 'x5t#S256')
  final String? x509sha256Thumbprint;

  JsonWebHeader({
    required this.type,
    this.contentType,
    required this.algorithm,
    this.jwkSetUri,
    this.jwk,
    this.keyId,
    this.x509Uri,
    this.x509CertChain,
    this.x509sha1Thumbprint,
    this.x509sha256Thumbprint,
  }) : assert(algorithm.isValid);

  @override
  List<Object?> get props => [
        type,
        contentType,
        algorithm,
        jwkSetUri,
        jwk,
        keyId,
        x509Uri,
        x509CertChain,
        x509sha1Thumbprint,
        x509sha256Thumbprint,
      ];

  factory JsonWebHeader.fromJson(Map<String, dynamic> json) =>
      _$JsonWebHeaderFromJson(json);

  Map<String, dynamic> toJson() => _$JsonWebHeaderToJson(this);

  List<int> encode() => utf8.encode(jsonEncode(toJson()));

  String encodeBase64() => base64RawUrl.encode(encode());

  void assertValid() {
    if (type == TokenType.DPoP) {
      if (jwk == null) {
        throw MissingParameterExeception('jwk');
      }
    }
  }
}
