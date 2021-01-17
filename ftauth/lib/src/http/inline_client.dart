import 'package:http/http.dart' as http;

typedef HttpHandler = Future<http.StreamedResponse> Function(
    http.BaseRequest request);

class InlineClient extends http.BaseClient {
  final HttpHandler _send;
  final Duration _timeout;

  InlineClient({required HttpHandler send, Duration? timeout})
      : _send = send,
        _timeout = timeout ?? const Duration(seconds: 30);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _send(request).timeout(_timeout);
  }
}
