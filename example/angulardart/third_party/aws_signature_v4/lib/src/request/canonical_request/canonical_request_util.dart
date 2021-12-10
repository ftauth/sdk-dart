part of 'canonical_request.dart';

/// Decodes a query parameter if it's encoded.
///
/// Used to prevent double-encoding unless required.
String _decodeIfNeeded(String queryComponent) {
  return queryComponent.contains('%')
      ? Uri.decodeComponent(queryComponent)
      : queryComponent;
}

/// The SHA-256/Hex-encoded hash for empty requests.
const emptyPayloadHash =
    'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';

/// Hashes payload bytes using SHA-256 and encodes using hex.
const payloadEncoder = _CanonicalPayloadEncoder();

class _CanonicalPayloadEncoder extends Converter<List<int>?, String> {
  const _CanonicalPayloadEncoder();

  @override
  String convert(List<int>? input) {
    if (input == null || input.isEmpty) {
      return emptyPayloadHash;
    }
    final hash = sha256.convert(input);
    final hexed = hex.encode(hash.bytes);
    return hexed.toLowerCase();
  }
}
