@TestOn('vm')

import 'dart:io';

import 'package:test/test.dart';
import 'package:path/path.dart' as path;
import 'package:ftauth/ftauth.dart';

import '../mock/mock_storage_repo.dart';

final throwsTLSException = throwsA(isA<TlsException>());
final throwsHandshakeException = throwsA(isA<HandshakeException>());

Future<void> main() async {
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
  final amazonDir = path.join(currentDir, 'amazon');
  final amazonCertChain = CertificateChain.loadChain(
    amazonUri,
    leafFilename: amazonDir + '/leaf.pem',
    intermediateFilename: amazonDir + '/int.pem',
    rootFilename: amazonDir + '/root.pem',
  );

  final emptyCert = Certificate(
    host: googleHost,
    certificate: '',
    type: CertificateType.root,
  );
  final emptyCertChain = CertificateChain(
    root: emptyCert,
    intermediate: emptyCert,
    leaf: emptyCert,
    host: googleHost,
  );

  final StorageRepo storageRepo = MockStorageRepo();

  late SSLRepo sslRepo;

  setUp(() {
    sslRepo = SSLRepoImpl(storageRepo);
  });

  tearDown(() async {
    await storageRepo.clear();
  });

  group('pinCert', () {
    test('invalid cert', () {
      expect(() async {
        sslRepo.pinCert(emptyCert);
      }, throwsTLSException);
    });

    test('valid certs', () {
      expect(() async {
        sslRepo.pinCert(googleCertChain.leaf);
      }(), completes);
      expect(() async {
        sslRepo.pinCert(googleCertChain.intermediate);
      }(), completes);
      expect(() async {
        sslRepo.pinCert(googleCertChain.root);
      }(), completes);
    });
  });

  group('pinCertChain', () {
    test('invalid format', () {
      expect(() async {
        CertificateChain.loadChain(
          googleUri,
          rootFilename: googleDir + '/root.cer',
          intermediateFilename: googleDir + '/int.cer',
          leafFilename: googleDir + '/leaf.cer',
        );
      }, throwsA(isA<FileSystemException>()));
    });

    test('invalid chain', () {
      expect(() async {
        sslRepo.pinCertChain(emptyCertChain);
      }, throwsTLSException);
    });

    test('valid chain', () {
      expect(() async {
        sslRepo.pinCertChain(googleCertChain);
      }(), completes);
    });
  });

  group('request', () {
    test('with valid cert chain, matching host', () {
      sslRepo.pinCertChain(googleCertChain);
      final client = sslRepo.client(googleHost);
      expect(client.get(googleUri), completes);
    });

    test('with valid cert chain, mismatched host', () {
      sslRepo.pinCertChain(amazonCertChain);
      final client = sslRepo.client(amazonHost);
      expect(client.get(googleUri), throwsHandshakeException);
    });

    test('with valid leaf cert, matching host', () {
      sslRepo.pinCert(googleCertChain.leaf);
      final client = sslRepo.client(googleHost);
      expect(client.get(googleUri), throwsHandshakeException);
    });

    test('with valid int cert, matching host', () {
      sslRepo.pinCert(googleCertChain.intermediate);
      final client = sslRepo.client(googleHost);
      expect(client.get(googleUri), completes);
    });

    test('with valid root cert, matching host', () {
      sslRepo.pinCert(googleCertChain.root);
      final client = sslRepo.client(googleHost);
      expect(client.get(googleUri), completes);
    });

    test('with valid leaf cert, mismatched host', () {
      sslRepo.pinCert(amazonCertChain.leaf);
      final client = sslRepo.client(amazonHost);
      expect(client.get(googleUri), throwsHandshakeException);
    });

    test('with valid int cert, mismatched host', () {
      sslRepo.pinCert(amazonCertChain.intermediate);
      final client = sslRepo.client(amazonHost);
      expect(client.get(googleUri), throwsHandshakeException);
    });

    test('with valid root cert, mismatched host', () {
      sslRepo.pinCert(amazonCertChain.root);
      final client = sslRepo.client(amazonHost);
      expect(client.get(googleUri), throwsHandshakeException);
    });
  });
}
