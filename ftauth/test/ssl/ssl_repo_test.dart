@TestOn('vm')

import 'dart:io';

import 'package:ftauth/ftauth.dart';
import 'package:ftauth/src/ssl/ssl_repo.dart';
import 'package:ftauth/src/ssl/ssl_repo_io.dart';
import 'package:ftauth/src/storage/storage_repo_impl.dart';
import 'package:hive/hive.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

final throwsTLSException = throwsA(isA<TlsException>());
final throwsHandshakeException = throwsA(isA<HandshakeException>());

class CertificateChain {
  final List<int> root;
  final List<int> intermediate;
  final List<int> leaf;
  final String host;

  CertificateChain({
    required this.root,
    required this.intermediate,
    required this.leaf,
    required this.host,
  });

  factory CertificateChain.loadChain(
    Uri host, {
    required String leafFilename,
    required String intermediateFilename,
    required String rootFilename,
  }) {
    return CertificateChain(
      host: '${host.scheme}://${host.host}',
      root: File(rootFilename).readAsBytesSync(),
      intermediate: File(intermediateFilename).readAsBytesSync(),
      leaf: File(leafFilename).readAsBytesSync(),
    );
  }

  List<List<int>> toBytes() => [root, intermediate, leaf];
}

Future<void> main() async {
  final projectRoot = Directory.current.path;
  final currentDir = path.join(projectRoot, 'test', 'ssl');

  final googleHost = Uri(scheme: 'https', host: 'google.com');
  final googleDir = path.join(currentDir, 'google');
  final googleCertChain = CertificateChain.loadChain(
    googleHost,
    leafFilename: googleDir + '/leaf.pem',
    intermediateFilename: googleDir + '/int.pem',
    rootFilename: googleDir + '/root.pem',
  );

  final amazonHost = Uri(scheme: 'https', host: 'amazon.com');
  final amazonDir = path.join(currentDir, 'amazon');
  final amazonCertChain = CertificateChain.loadChain(
    amazonHost,
    leafFilename: amazonDir + '/leaf.pem',
    intermediateFilename: amazonDir + '/int.pem',
    rootFilename: amazonDir + '/root.pem',
  );

  Hive.init(Directory.systemTemp.path);
  final StorageRepo storageRepo = StorageRepoImpl();
  await storageRepo.init();

  late SSLRepository sslRepo;

  setUp(() {
    sslRepo = SSLRepositoryImpl(storageRepo);
  });

  tearDown(() async {
    await storageRepo.clear();
  });

  group('pinCert', () {
    test('invalid cert', () {
      expect(() async {
        sslRepo.pinCert(googleHost, certBytes: []);
      }, throwsTLSException);
    });

    test('invalid cert without trusted roots', () {
      expect(() async {
        sslRepo.pinCert(googleHost, certBytes: [], withTrustedRoots: false);
      }, throwsTLSException);
    });

    test('invalid format', () {
      final derData = File(googleDir + '/root.cer').readAsBytesSync();
      expect(() async {
        sslRepo.pinCert(googleHost, certBytes: derData);
      }, throwsTLSException);
    });

    test('invalid format without trusted roots', () {
      final derData = File(googleDir + '/root.cer').readAsBytesSync();
      expect(() async {
        sslRepo.pinCert(googleHost,
            certBytes: derData, withTrustedRoots: false);
      }, throwsTLSException);
    });

    test('valid certs', () {
      expect(() async {
        sslRepo.pinCert(googleHost, certBytes: googleCertChain.leaf);
      }(), completes);
      expect(() async {
        sslRepo.pinCert(googleHost, certBytes: googleCertChain.intermediate);
      }(), completes);
      expect(() async {
        sslRepo.pinCert(googleHost, certBytes: googleCertChain.root);
      }(), completes);
    });

    test('valid certs without trusted roots', () {
      expect(() async {
        sslRepo.pinCert(googleHost,
            certBytes: googleCertChain.leaf, withTrustedRoots: false);
      }(), completes);
      expect(() async {
        sslRepo.pinCert(googleHost,
            certBytes: googleCertChain.intermediate, withTrustedRoots: false);
      }(), completes);
      expect(() async {
        sslRepo.pinCert(googleHost,
            certBytes: googleCertChain.root, withTrustedRoots: false);
      }(), completes);
    });
  });

  group('pinCertChain', () {
    test('invalid format', () {
      final invalidChain = CertificateChain.loadChain(
        googleHost,
        rootFilename: googleDir + '/root.cer',
        intermediateFilename: googleDir + '/int.cer',
        leafFilename: googleDir + '/leaf.cer',
      );
      expect(() async {
        sslRepo.pinCertChain(googleHost, certBytes: invalidChain.toBytes());
      }, throwsTLSException);
    });

    test('invalid format without trusted roots', () {
      final invalidChain = CertificateChain.loadChain(
        googleHost,
        rootFilename: googleDir + '/root.cer',
        intermediateFilename: googleDir + '/int.cer',
        leafFilename: googleDir + '/leaf.cer',
      );
      expect(() async {
        sslRepo.pinCertChain(
          googleHost,
          certBytes: invalidChain.toBytes(),
          withTrustedRoots: false,
        );
      }, throwsTLSException);
    });

    test('invalid chain', () {
      expect(() async {
        sslRepo.pinCertChain(
          googleHost,
          certBytes: [[], [], []],
        );
      }, throwsTLSException);
    });

    test('invalid chain without trusted roots', () {
      expect(() async {
        sslRepo.pinCertChain(
          googleHost,
          certBytes: [[], [], []],
          withTrustedRoots: false,
        );
      }, throwsTLSException);
    });

    test('empty chain', () {
      expect(() async {
        sslRepo.pinCertChain(
          googleHost,
          certBytes: [],
        );
      }(), completes);
    });

    test('empty chain without trusted roots', () {
      expect(() async {
        sslRepo.pinCertChain(
          googleHost,
          certBytes: [],
          withTrustedRoots: false,
        );
      }(), completes);
    });

    test('valid chain', () {
      expect(() async {
        sslRepo.pinCertChain(googleHost, certBytes: googleCertChain.toBytes());
      }(), completes);
    });

    test('valid chain without trusted roots', () {
      expect(() async {
        sslRepo.pinCertChain(
          googleHost,
          certBytes: googleCertChain.toBytes(),
          withTrustedRoots: false,
        );
      }(), completes);
    });
  });

  group('request', () {
    test('trusted roots, with valid cert chain, matching host', () {
      sslRepo.pinCertChain(googleHost, certBytes: googleCertChain.toBytes());
      final client = sslRepo.client(googleHost.toString());
      expect(client.getUrl(googleHost), completes);
    });

    test('no trusted roots, with valid cert chain, matching host', () {
      sslRepo.pinCertChain(
        googleHost,
        certBytes: googleCertChain.toBytes(),
        withTrustedRoots: false,
      );
      final client = sslRepo.client(googleHost.toString());
      expect(client.getUrl(googleHost), completes);
    });

    test('trusted roots, with valid cert chain, mismatched host', () {
      sslRepo.pinCertChain(googleHost, certBytes: amazonCertChain.toBytes());
      final client = sslRepo.client(googleHost.toString());
      expect(client.getUrl(googleHost), completes);
    });

    test('no trusted roots, with valid cert chain, mismatched host', () {
      sslRepo.pinCertChain(
        googleHost,
        certBytes: amazonCertChain.toBytes(),
        withTrustedRoots: false,
      );
      final client = sslRepo.client(googleHost.toString());
      expect(client.getUrl(googleHost), throwsHandshakeException);
    });

    test('trusted roots, with valid leaf cert, matching host', () {
      sslRepo.pinCert(googleHost, certBytes: googleCertChain.leaf);
      final client = sslRepo.client(googleHost.toString());
      expect(client.getUrl(googleHost), completes);
    });

    test('trusted roots, with valid int cert, matching host', () {
      sslRepo.pinCert(googleHost, certBytes: googleCertChain.intermediate);
      final client = sslRepo.client(googleHost.toString());
      expect(client.getUrl(googleHost), completes);
    });

    test('trusted roots, with valid root cert, matching host', () {
      sslRepo.pinCert(googleHost, certBytes: googleCertChain.root);
      final client = sslRepo.client(googleHost.toString());
      expect(client.getUrl(googleHost), completes);
    });

    test('no trusted roots, with valid leaf cert, matching host', () {
      sslRepo.pinCert(
        googleHost,
        certBytes: googleCertChain.leaf,
        withTrustedRoots: false,
      );
      final client = sslRepo.client(googleHost.toString());
      expect(client.getUrl(googleHost), throwsHandshakeException);
    });

    test('no trusted roots, with valid int cert, matching host', () {
      sslRepo.pinCert(
        googleHost,
        certBytes: googleCertChain.intermediate,
        withTrustedRoots: false,
      );
      final client = sslRepo.client(googleHost.toString());
      expect(client.getUrl(googleHost), completes);
    });

    test('no trusted roots, with valid root cert, matching host', () {
      sslRepo.pinCert(
        googleHost,
        certBytes: googleCertChain.root,
        withTrustedRoots: false,
      );
      final client = sslRepo.client(googleHost.toString());
      expect(client.getUrl(googleHost), completes);
    });

    test('trusted roots, with valid leaf cert, mismatched host', () {
      sslRepo.pinCert(googleHost, certBytes: amazonCertChain.leaf);
      final client = sslRepo.client(googleHost.toString());
      expect(client.getUrl(googleHost), completes);
    });

    test('trusted roots, with valid int cert, mismatched host', () {
      sslRepo.pinCert(googleHost, certBytes: amazonCertChain.intermediate);
      final client = sslRepo.client(googleHost.toString());
      expect(client.getUrl(googleHost), completes);
    });

    test('trusted roots, with valid root cert, mismatched host', () {
      sslRepo.pinCert(googleHost, certBytes: amazonCertChain.root);
      final client = sslRepo.client(googleHost.toString());
      expect(client.getUrl(googleHost), completes);
    });

    test('no trusted roots, with valid leaf cert, mismatched host', () {
      sslRepo.pinCert(
        googleHost,
        certBytes: amazonCertChain.leaf,
        withTrustedRoots: false,
      );
      final client = sslRepo.client(googleHost.toString());
      expect(client.getUrl(googleHost), throwsHandshakeException);
    });

    test('no trusted roots, with valid int cert, mismatched host', () {
      sslRepo.pinCert(
        googleHost,
        certBytes: amazonCertChain.intermediate,
        withTrustedRoots: false,
      );
      final client = sslRepo.client(googleHost.toString());
      expect(client.getUrl(googleHost), throwsHandshakeException);
    });

    test('no trusted roots, with valid root cert, mismatched host', () {
      sslRepo.pinCert(
        googleHost,
        certBytes: amazonCertChain.root,
        withTrustedRoots: false,
      );
      final client = sslRepo.client(googleHost.toString());
      expect(client.getUrl(googleHost), throwsHandshakeException);
    });
  });
}
