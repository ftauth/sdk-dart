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
  final googleCertChain = await CertificateChain.load(
    googleUri,
    leafUri: Uri.file(googleDir + '/leaf.pem'),
    intermediateUri: Uri.file(googleDir + '/int.pem'),
    rootUri: Uri.file(googleDir + '/root.pem'),
  );

  const amazonHost = 'amazon.com';
  final amazonUri = Uri(scheme: 'https', host: amazonHost);
  final amazonDir = path.join(currentDir, 'amazon');
  final amazonCertChain = await CertificateChain.load(
    amazonUri,
    leafUri: Uri.file(amazonDir + '/leaf.pem'),
    intermediateUri: Uri.file(amazonDir + '/int.pem'),
    rootUri: Uri.file(amazonDir + '/root.pem'),
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
        await CertificateChain.load(
          googleUri,
          leafUri: Uri.file(googleDir + '/leaf.cer'),
          intermediateUri: Uri.file(googleDir + '/int.cer'),
          rootUri: Uri.file(googleDir + '/root.cer'),
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
    group('with valid cert chain, matching host', () {
      test('amazon', () {
        sslRepo.pinCertChain(amazonCertChain);
        final client = sslRepo.client(amazonHost);
        expect(client.get(amazonUri), completes);
      });

      test('google', () {
        sslRepo.pinCertChain(googleCertChain);
        final client = sslRepo.client(googleHost);
        expect(client.get(googleUri), completes);
      });
    });

    group('with valid leaf cert, matching host', () {
      test('amazon', () {
        sslRepo.pinCert(amazonCertChain.leaf);
        final client = sslRepo.client(amazonHost);
        expect(client.get(amazonUri), throwsHandshakeException);
      });

      test('google', () {
        sslRepo.pinCert(googleCertChain.leaf);
        final client = sslRepo.client(googleHost);
        expect(client.get(googleUri), throwsHandshakeException);
      });
    });

    group('with valid int cert, matching host', () {
      test('amazon', () {
        sslRepo.pinCert(amazonCertChain.intermediate);
        final client = sslRepo.client(amazonHost);
        expect(client.get(amazonUri), completes);
      });

      test('google', () {
        sslRepo.pinCert(googleCertChain.intermediate);
        final client = sslRepo.client(googleHost);
        expect(client.get(googleUri), completes);
      });
    });

    group('with valid root cert, matching host', () {
      test('amazon', () {
        sslRepo.pinCert(amazonCertChain.root);
        final client = sslRepo.client(amazonHost);
        expect(client.get(amazonUri), completes);
      });

      test('google', () {
        sslRepo.pinCert(googleCertChain.root);
        final client = sslRepo.client(googleHost);
        expect(client.get(googleUri), completes);
      });
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

    test('with valid cert chain, mismatched host', () async {
      sslRepo.pinCertChain(amazonCertChain);
      final client = sslRepo.client(amazonHost);
      expect(client.get(googleUri), throwsHandshakeException);
    });
  });
}
