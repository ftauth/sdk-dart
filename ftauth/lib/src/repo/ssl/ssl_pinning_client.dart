import 'package:ftauth/src/repo/ssl/ssl_repo.dart';
import 'package:http/http.dart' as http;

/// An HTTP client which pins SSL certificates.
class SSLPinningClient extends http.BaseClient {
  final SSLRepo _sslRepository;
  final http.Client _baseClient;
  final Duration _timeout;

  SSLPinningClient(
    this._sslRepository, {
    http.Client? baseClient,
    Duration? timeout,
  })  : _baseClient = baseClient ?? http.Client(),
        _timeout = timeout ?? const Duration(seconds: 60);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final host = request.url.host;
    if (_sslRepository.isPinning(host)) {
      return _sslRepository.client(host).send(request).timeout(_timeout);
    } else {
      return _baseClient.send(request).timeout(_timeout);
    }
  }
}
