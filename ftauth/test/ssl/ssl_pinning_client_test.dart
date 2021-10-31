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
  late final CertificateChain googleCertChain;

  const amazonHost = 'amazon.com';
  final amazonUri = Uri(scheme: 'https', host: amazonHost);

  final StorageRepo storageRepo = MockStorageRepo();

  late SSLRepo sslRepo;
  late SSLPinningClient sslPinningClient;

  setUpAll(() async {
    googleCertChain = await CertificateChain.load(
      googleUri,
      leafUri: Uri.file(googleDir + '/leaf.pem'),
      intermediateUri: Uri.file(googleDir + '/int.pem'),
      rootUri: Uri.file(googleDir + '/root.pem'),
    );
  });

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
