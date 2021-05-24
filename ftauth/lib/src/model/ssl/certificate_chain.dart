import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'certificate_type.dart';
import 'certificate.dart';

part 'certificate_chain.g.dart';

@JsonSerializable()
class CertificateChain extends Equatable {
  final Certificate root;
  final Certificate intermediate;
  final Certificate leaf;
  final String host;

  CertificateChain({
    required this.root,
    required this.intermediate,
    required this.leaf,
    required this.host,
  });

  @override
  List<Object?> get props => [host, root, intermediate, leaf];

  factory CertificateChain.loadChain(
    Uri host, {
    required String leafFilename,
    required String intermediateFilename,
    required String rootFilename,
  }) {
    return CertificateChain(
      host: host.host,
      root: Certificate(
        host: host.host,
        type: CertificateType.root,
        certificate: File(rootFilename).readAsStringSync(),
      ),
      intermediate: Certificate(
        host: host.host,
        type: CertificateType.intermediate,
        certificate: File(intermediateFilename).readAsStringSync(),
      ),
      leaf: Certificate(
        host: host.host,
        type: CertificateType.leaf,
        certificate: File(leafFilename).readAsStringSync(),
      ),
    );
  }

  factory CertificateChain.fromJson(Map<String, dynamic> json) =>
      _$CertificateChainFromJson(json);

  Map<String, dynamic> toJson() => _$CertificateChainToJson(this);

  List<List<int>> get bytes => [root.bytes, intermediate.bytes, leaf.bytes];
}
