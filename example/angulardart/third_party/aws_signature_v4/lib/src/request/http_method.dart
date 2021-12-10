/// Valid HTTP methods for AWS requests.
enum HttpMethod {
  get,
  head,
  post,
  put,
  patch,
  delete,
}

/// Helpers for [HttpMethod].
extension HttpMethodX on HttpMethod {
  static HttpMethod fromString(String str) =>
      HttpMethod.values.firstWhere((el) => str.toUpperCase() == el.value);

  /// {@template http_method_value}
  /// Returns the uppercased HTTP method, e.g. 'POST'.
  /// {@endtemplate}
  String get value => toString().split('.')[1].toUpperCase();

  /// {@macro http_method_value}
  String canonicalize() => value.toUpperCase();

  bool get hasBody {
    switch (this) {
      case HttpMethod.post:
      case HttpMethod.put:
      case HttpMethod.patch:
        return true;
      default:
        return false;
    }
  }
}
