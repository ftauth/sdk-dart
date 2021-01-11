import 'package:ftauth/src/dpop/dpop_repo.dart';
import 'package:http/http.dart' as http;

/// An HTTP client which adds DPoP proofs to requests.
class DPoPClient extends http.BaseClient {
  final DPoPRepo dPoPRepo;
  final http.Client? client;

  DPoPClient(this.dPoPRepo, {this.client});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final proof = await dPoPRepo.createProof(
      request.method,
      request.url,
    );
    request.headers['Authorization'] = 'DPoP $proof';
    if (client != null) {
      return client!.send(request);
    }
    return request.send();
  }
}
