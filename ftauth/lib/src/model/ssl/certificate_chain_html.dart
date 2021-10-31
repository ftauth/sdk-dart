import 'package:ftauth/src/model/model.dart';

Future<CertificateChain> loadChain(
  Uri host, {
  required Uri leafUri,
  required Uri intermediateUri,
  required Uri rootUri,
}) async {
  throw UnsupportedError('SSL Pinning is not supported on Web');
}
