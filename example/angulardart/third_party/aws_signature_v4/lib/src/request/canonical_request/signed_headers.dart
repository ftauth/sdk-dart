part of 'canonical_request.dart';

/// The signed headers for a canonical request.
class SignedHeaders extends DelegatingIterable<String> {
  SignedHeaders(Map<String, String> headers) : super(headers.keys);

  /// Creates the signed headers string.
  @override
  String toString() {
    return map((header) => header.toLowerCase()).join(';');
  }
}
