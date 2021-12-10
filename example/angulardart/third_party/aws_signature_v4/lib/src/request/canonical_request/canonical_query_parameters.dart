part of 'canonical_request.dart';

/// {@template canonical_query_parameters}
/// A map of canonicalized query parameters.
/// {@endtemplate}
class CanonicalQueryParameters extends DelegatingMap<String, String> {
  /// {@macro canonical_query_parameters}
  CanonicalQueryParameters(Map<String, String> queryParameters)
      : super(canonicalize(queryParameters));

  /// Encodes and sorts the query parameters.
  static Map<String, String> canonicalize(
    Map<String, String> queryParameters,
  ) {
    final encodedEntries = queryParameters.entries.map((e) => MapEntry(
          Uri.encodeComponent(_decodeIfNeeded(e.key)),
          Uri.encodeComponent(_decodeIfNeeded(e.value)),
        ));
    final sortedParameters = LinkedHashMap.fromEntries(
      encodedEntries.toList()
        ..sort(
          (a, b) {
            final keyCompare = a.key.compareTo(b.key);
            if (keyCompare != 0) {
              return keyCompare;
            }
            return a.value.compareTo(b.value);
          },
        ),
    );

    return sortedParameters;
  }

  /// Returns the sorted, encoded query string.
  @override
  String toString() {
    return entries.map((e) => '${e.key}=${e.value}').join('&');
  }
}
