import 'dart:io';

import 'certificate.dart';
import 'certificate_chain.dart';
import 'certificate_type.dart';

Future<CertificateChain> loadChain(
  Uri host, {
  required Uri leafUri,
  required Uri intermediateUri,
  required Uri rootUri,
}) async {
  return CertificateChain(
    host: host.host,
    root: Certificate(
      host: host.host,
      type: CertificateType.root,
      certificate: await File.fromUri(rootUri).readAsString(),
    ),
    intermediate: Certificate(
      host: host.host,
      type: CertificateType.intermediate,
      certificate: await File.fromUri(intermediateUri).readAsString(),
    ),
    leaf: Certificate(
      host: host.host,
      type: CertificateType.leaf,
      certificate: await File.fromUri(leafUri).readAsString(),
    ),
  );
}
