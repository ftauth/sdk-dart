import 'dart:io';

import 'package:path/path.dart' as path;

const outDir = 'test/ssl';
const _start = '-----BEGIN CERTIFICATE-----';
const _end = '-----END CERTIFICATE-----';

Future<void> main() async {
  for (var host in ['amazon.com', 'google.com']) {
    final certChain = await _downloadCertChain(host);
    _saveCertificateChain(host, certChain);
  }
}

void _saveCertificateChain(String host, String certChain) {
  const certNames = ['leaf', 'int', 'root'];
  var index = 0, endIndex = 0;
  for (var i = 0; i < 3; i++) {
    index = certChain.indexOf(_start, index + 1);
    endIndex = certChain.indexOf(_end, index) + _end.length;
    var certName = certNames[i] + '.pem';
    var hostDir = host.split('.').first;
    var cert = certChain.substring(index, endIndex);
    var outFile = File(path.join(outDir, hostDir, certName))
      ..createSync(recursive: true);
    outFile.writeAsStringSync(cert);
  }
}

Future<String> _downloadCertChain(String host) async {
  final result = await Process.run(
    'openssl',
    [
      's_client',
      '-host',
      host,
      '-port',
      '443',
      '-prexit',
      '-showcerts',
    ],
  );

  if (result.exitCode != 0) {
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    exit(result.exitCode);
  }

  return result.stdout;
}
