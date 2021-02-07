import 'dart:io';

import 'package:ftauth/ftauth.dart';

import 'ssl_repo.dart';

class SSLRepositoryImpl extends SSLRepository {
  final StorageRepo _storageRepo;
  final bool? withTrustedRoots;

  SSLRepositoryImpl(this._storageRepo, {this.withTrustedRoots});

  final _contexts = <String, SecurityContext>{};

  /// The HTTP client with the imposed security constraints.
  @override
  HttpClient client(String host) {
    return HttpClient(context: _contexts[host]);
  }

  @override
  void pinCert(
    Uri host, {
    List<int>? certBytes,
    String? cert,
    bool withTrustedRoots = true,
  }) {
    if (certBytes == null && cert == null) {
      throw ArgumentError('certBytes or cert must be provided');
    }
    final context = SecurityContext(
        withTrustedRoots: this.withTrustedRoots ?? withTrustedRoots);
    if (cert != null) {
      certBytes = cert.codeUnits;
    }
    context.setTrustedCertificatesBytes(certBytes!);
    String hostname;
    if (host.hasPort) {
      hostname = '${host.scheme}://${host.host}:${host.port}';
    } else {
      hostname = '${host.scheme}://${host.host}';
    }
    _contexts[hostname] = context;
  }

  @override
  void pinCertChain(
    Uri host, {
    List<List<int>>? certBytes,
    List<String>? certs,
    bool withTrustedRoots = true,
  }) {
    if (certBytes == null && certs == null) {
      throw ArgumentError('certBytes or certs must be provided');
    }
    final context = SecurityContext(
        withTrustedRoots: this.withTrustedRoots ?? withTrustedRoots);
    if (certs != null) {
      certBytes = certs.map((cert) => cert.codeUnits).toList();
    }
    for (var bytes in certBytes!) {
      context.setTrustedCertificatesBytes(bytes);
    }
    String hostname;
    if (host.hasPort) {
      hostname = '${host.scheme}://${host.host}:${host.port}';
    } else {
      hostname = '${host.scheme}://${host.host}';
    }
    _contexts[hostname] = context;
  }
}
