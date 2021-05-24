import 'dart:convert';
import 'dart:io';

import 'package:ftauth/ftauth.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import 'keys.dart';
import 'ssl_repo.dart';

class SSLRepoImpl extends SSLRepo {
  final StorageRepo _storageRepo;
  final bool? withTrustedRoots;

  /// A cache of all pinned certificates.
  Map<String, Certificate> _certificates = {};

  /// A cache of all pinned certificate chains.
  Map<String, CertificateChain> _certificateChains = {};

  /// A cache of all current contexts.
  final _contexts = <String, SecurityContext>{};

  /// A cache of all current clients.
  final _clients = <String, IOClient>{};

  SSLRepoImpl(this._storageRepo, {this.withTrustedRoots})
      : super(_storageRepo, withTrustedRoots: withTrustedRoots);

  Future<void> init() async {
    final storedPins = await _storageRepo.getString(keyPinnedCertificates);
    if (storedPins != null) {
      _certificates = (jsonDecode(storedPins) as Map).map((host, cert) {
        return MapEntry(host, Certificate.fromJson(cert));
      });
      for (final certificate in _certificates.values) {
        pinCert(certificate, writeToStorage: false);
      }
    }

    final storedChains =
        await _storageRepo.getString(keyPinnedCertificateChains);
    if (storedChains != null) {
      _certificateChains = (jsonDecode(storedChains) as Map).map((host, cert) {
        return MapEntry(host, CertificateChain.fromJson(cert));
      });
      for (final certificateChain in _certificateChains.values) {
        pinCertChain(certificateChain, writeToStorage: false);
      }
    }
  }

  @override
  http.Client client(String host) {
    if (!isPinning(host)) {
      throw ArgumentError('Host has not been pinned yet.');
    }
    return _clients[host] ??= IOClient(HttpClient(context: _contexts[host]));
  }

  @override
  bool isPinning(String host) => _contexts.containsKey(host);

  @override
  void pinCert(
    Certificate certificate, {
    bool writeToStorage = true,
  }) {
    final context = SecurityContext(withTrustedRoots: false);
    context.setTrustedCertificatesBytes(certificate.bytes);
    _contexts[certificate.host] = context;

    // Remove old client, if present
    _clients.remove(certificate.host)?.close();

    if (writeToStorage) {
      _storeCertificate(certificate);
    }
  }

  @override
  void pinCertChain(
    CertificateChain certificateChain, {
    bool writeToStorage = true,
  }) {
    final context = SecurityContext(withTrustedRoots: false);
    for (var bytes in certificateChain.bytes) {
      context.setTrustedCertificatesBytes(bytes);
    }
    _contexts[certificateChain.host] = context;

    // Remove old client, if present
    _clients.remove(certificateChain.host)?.close();

    if (writeToStorage) {
      _storeCertificateChain(certificateChain);
    }
  }

  Future<void> _storeCertificate(Certificate certificate) {
    _certificates[certificate.host] = certificate;
    return _storageRepo.setString(
      keyPinnedCertificates,
      jsonEncode(_certificates),
    );
  }

  Future<void> _storeCertificateChain(CertificateChain chain) {
    _certificateChains[chain.host] = chain;
    return _storageRepo.setString(
      keyPinnedCertificateChains,
      jsonEncode(_certificateChains),
    );
  }
}
