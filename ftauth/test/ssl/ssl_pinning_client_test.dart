@TestOn('vm')

import 'dart:io';

import 'package:test/test.dart';
import 'package:path/path.dart' as path;
import 'package:ftauth/ftauth.dart';

import '../mock/mock_storage_repo.dart';

void main() {
  final projectRoot = Directory.current.path;
  final currentDir = path.join(projectRoot, 'test', 'ssl');

  const googleHost = 'google.com';
  final googleUri = Uri(scheme: 'https', host: googleHost);
  final googleDir = path.join(currentDir, 'google');
  final googleCertChain = CertificateChain.loadChain(
    googleUri,
    leafFilename: googleDir + '/leaf.pem',
    intermediateFilename: googleDir + '/int.pem',
    rootFilename: googleDir + '/root.pem',
  );

  const amazonHost = 'amazon.com';
  final amazonUri = Uri(scheme: 'https', host: amazonHost);

  final StorageRepo storageRepo = MockStorageRepo();

  late SSLRepo sslRepo;
  late SSLPinningClient sslPinningClient;

  setUp(() {
    sslRepo = SSLRepoImpl(storageRepo);
    sslPinningClient = SSLPinningClient(sslRepo);
  });

  tearDown(() async {
    await storageRepo.clear();
  });

  group('request', () {
    test('succeeds for all pinned and non-pinned hosts', () {
      sslRepo.pinCert(googleCertChain.intermediate);
      expect(sslPinningClient.get(googleUri), completes);
      expect(sslPinningClient.get(amazonUri), completes);
    });
  });
}
