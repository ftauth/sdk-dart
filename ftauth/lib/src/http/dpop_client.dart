import 'package:ftauth/src/dpop/dpop_repo.dart';
import 'package:http/http.dart' as http;

/// An HTTP client which adds DPoP proofs to requests.
class DPoPClient extends http.BaseClient {
  final DPoPRepo dPoPRepo;
  final http.Client client;

  DPoPClient(this.dPoPRepo, {http.Client? client})
      : client = client ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request.url.path.endsWith('/token')) {
      final proof = await dPoPRepo.createProof(
        request.method,
        request.url,
      );
      request.headers['DPoP'] = proof;
    }
    return client.send(request);
  }
}
