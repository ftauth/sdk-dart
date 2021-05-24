class ApiException implements Exception {
  final String method;
  final Uri url;
  final int statusCode;
  final String body;

  const ApiException(this.method, this.url, this.statusCode, [this.body = '']);

  ApiException.get(this.url, this.statusCode, [this.body = ''])
      : method = 'GET';

  ApiException.post(this.url, this.statusCode, [this.body = ''])
      : method = 'POST';

  ApiException.put(this.url, this.statusCode, [this.body = ''])
      : method = 'PUT';

  ApiException.delete(this.url, this.statusCode, [this.body = ''])
      : method = 'DELETE';

  @override
  String toString() {
    if (statusCode == 401) {
      return '$method $url: Unauthorized';
    }
    return "$method $url: $statusCode - '$body'";
  }
}

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  factory AuthException.uninitialized() =>
      AuthException('Authentication has not been initialized.');

  factory AuthException.unauthenticated() =>
      AuthException('User is not authenticated');

  static const unknown = AuthException('An unknown error occurred.');

  @override
  String toString() {
    return message;
  }
}
