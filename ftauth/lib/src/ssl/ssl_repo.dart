import 'dart:io';

abstract class SSLRepository {
  const SSLRepository();

  HttpClient client(String host);
  void pinCert(
    Uri host, {
    List<int>? certBytes,
    String? cert,
    bool withTrustedRoots = true,
  });
  void pinCertChain(
    Uri host, {
    List<List<int>>? certBytes,
    List<String>? certs,
    bool withTrustedRoots = true,
  });
}
