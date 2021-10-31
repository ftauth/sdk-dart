import 'certificate_chain_stub.dart'
    if (dart.library.io) 'certificate_chain_io.dart'
    if (dart.library.html) 'certificate_chain_html.dart';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

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

  static Future<CertificateChain> load(
    Uri host, {
    required Uri leafUri,
    required Uri intermediateUri,
    required Uri rootUri,
  }) {
    return loadChain(
      host,
      leafUri: leafUri,
      intermediateUri: intermediateUri,
      rootUri: rootUri,
    );
  }

  factory CertificateChain.fromJson(Map<String, dynamic> json) =>
      _$CertificateChainFromJson(json);

  Map<String, dynamic> toJson() => _$CertificateChainToJson(this);

  List<List<int>> get bytes => [root.bytes, intermediate.bytes, leaf.bytes];
}
