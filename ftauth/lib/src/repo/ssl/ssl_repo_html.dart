import 'package:ftauth/ftauth.dart';
import 'package:http/http.dart' as http;

class SSLRepoImpl extends SSLRepo {
  static final _httpClient = http.Client();

  SSLRepoImpl(StorageRepo storageRepo, {bool? withTrustedRoots})
      : super(
          storageRepo,
          withTrustedRoots: withTrustedRoots,
        );

  @override
  http.Client client(String host) {
    FTAuth.warn('SSL Pinning is not supported on Web');
    return _httpClient;
  }

  @override
  Future<void> init() async {}

  @override
  bool isPinning(String host) => false;

  @override
  void pinCert(Certificate certificate) {
    FTAuth.warn('SSL Pinning is not supported on Web');
  }

  @override
  void pinCertChain(CertificateChain certificateChain) {
    FTAuth.warn('SSL Pinning is not supported on Web');
  }
}
