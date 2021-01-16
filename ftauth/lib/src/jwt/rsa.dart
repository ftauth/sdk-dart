import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'prefs.dart';
import 'util.dart';

part 'rsa.g.dart';

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
