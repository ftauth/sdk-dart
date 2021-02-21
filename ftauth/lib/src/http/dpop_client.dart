import 'package:ftauth/ftauth.dart';
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
      final token = await dPoPRepo.createToken(
        request.method,
        request.url,
      );
      request.headers['DPoP'] = await token.encodeBase64(CryptoRepo.instance);
      print('Sending: ${token.header.jwk!.n.toString()}');
      print('Sending: ${token.header.jwk!.e.toString()}');
    }
    return client.send(request);
  }
}
