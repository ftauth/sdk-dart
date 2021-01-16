import 'package:http/http.dart' as http;

typedef HttpHandler = Future<http.StreamedResponse> Function(
    http.BaseRequest request);

class InlineClient extends http.BaseClient {
  final HttpHandler _send;

  InlineClient({required HttpHandler send}) : _send = send;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _send(request);
  }
}
