import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'certificate_type.dart';

part 'certificate.g.dart';

@JsonSerializable()
class Certificate extends Equatable {
  /// The domain name of the pinned certificate.
  ///
  /// e.g. For a URL `https://medtronic.com:443/path`, the host is `medtronic.com`
  final String host;

  /// The PEM-encoded certificate.
  final String certificate;

  final CertificateType type;

  @JsonKey(ignore: true)
  final List<int> bytes;

  Certificate({
    required this.host,
    required this.certificate,
    required this.type,
  })  : assert(
          Uri.parse('https://$host').host == host,
          'Invalid host format. Use only the domain name.',
        ),
        bytes = certificate.codeUnits;

  @override
  List<Object?> get props => [host, certificate, type];

  factory Certificate.fromJson(Map<String, dynamic> json) =>
      _$CertificateFromJson(json);

  Map<String, dynamic> toJson() => _$CertificateToJson(this);
}
