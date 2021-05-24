import 'package:ftauth/ftauth.dart';
import 'package:http/http.dart' as http;

import 'ssl_repo.dart';

class SSLRepoImpl extends SSLRepo {
  SSLRepoImpl(StorageRepo storageRepo, {bool? withTrustedRoots})
      : super(
          storageRepo,
          withTrustedRoots: withTrustedRoots,
        );

  @override
  http.Client client(String host) {
    throw UnimplementedError();
  }

  @override
  Future<void> init() {
    throw UnimplementedError();
  }

  @override
  bool isPinning(String host) {
    throw UnimplementedError();
  }

  @override
  void pinCert(Certificate certificate) {
    throw UnimplementedError();
  }

  @override
  void pinCertChain(CertificateChain certificateChain) {
    throw UnimplementedError();
  }
}
