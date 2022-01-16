import 'package:ftauth/ftauth.dart';
import 'package:http/http.dart' as http;

export 'ssl_repo_stub.dart'
    if (dart.library.io) 'ssl_repo_io.dart'
    if (dart.library.html) 'ssl_repo_html.dart';

abstract class SSLRepo implements SSLPinningInterface {
  SSLRepo(StorageRepo storageRepo, {bool? withTrustedRoots});

  /// Gets a pinning HTTP client for the given [host].
  http.Client client(String host);

  /// Initializes the repository by loading its state from storage.
  Future<void> init();

  /// Creates a strict pinning to a given [certificateChain] for a particular host.
  ///
  /// When an HTTP request is made to a URL with the specified host, the SSL
  /// certificate chain that the server presents must match this one. Otherwise,
  /// the connection will not be allowed.
  void pinCertChain(CertificateChain certificateChain);
}

abstract class SSLPinningInterface {
  /// Returns true if the repository is currently pinning for [host].
  bool isPinning(String host);

  /// Creates a strict pinning to the given [certificate] for a particular host.
  ///
  /// When an HTTP request is made to a URL with the specified host, the SSL
  /// certificate chain that the server presents must include a root certificate
  /// matching this one. Otherwise, the connection will not be allowed.
  void pinCert(Certificate certificate);
}
