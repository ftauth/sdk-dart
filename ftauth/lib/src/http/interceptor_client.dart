import 'package:http/http.dart' as http;

typedef Interceptor = Future<void> Function(
    http.BaseRequest request, http.StreamedResponse);

/// A client which intercepts all HTTP request/response pairs and performs
/// some action on them before passing the response onto the underlying `client`.
class InterceptorClient extends http.BaseClient {
  final http.Client client;
  final List<Interceptor> interceptors;

  InterceptorClient(
    this.client, [
    this.interceptors = const [],
  ]);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await client.send(request);
    for (var interceptor in interceptors) {
      interceptor(request, response);
    }
    return response;
  }
}
