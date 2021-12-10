import 'package:aws_common/aws_common.dart';
import 'package:collection/collection.dart';

class GraphQLResponseErrors extends DelegatingList<GraphQLResponseError>
    implements Exception {
  const GraphQLResponseErrors(List<GraphQLResponseError> errors)
      : super(errors);
}

/// {@template graphql_response_error}
/// Contains an error produced via a GraphQL invocation. Corresponds to one
/// entry in the `errors` field on a GraphQL response.
///
/// [locations] and [path] may be null.
/// {@endtemplate}
class GraphQLResponseError
    with AWSEquatable<GraphQLResponseError>, AWSSerializable {
  /// The description of the error.
  final String message;

  /// The locations of the error-causing fields in the request document.
  final List<GraphQLResponseErrorLocation>? locations;

  /// The key path of the error-causing field in the response's `data` object.
  final List<dynamic>? path;

  /// {@macro graphql_response_error}
  const GraphQLResponseError({
    required this.message,
    this.locations,
    this.path,
  });

  @override
  List<Object?> get props => [message, locations, path];

  factory GraphQLResponseError.fromJson(Map<String, dynamic> json) {
    return GraphQLResponseError(
      message: json['message'] as String,
      locations: (json['locations'] as List?)
          ?.cast<Map>()
          .map((json) => GraphQLResponseErrorLocation.fromJson(
                json.cast<String, dynamic>(),
              ))
          .toList(),
      path: json['path'] as List?,
    );
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'message': message,
        if (locations != null) 'locations': locations,
        if (path != null) 'path': path,
      };
}

/// {@template graphql_response_error_location}
/// Represents a location in the GraphQL request document where an error occurred.
/// [line] and [column] correspond to the beginning of the syntax element associated
/// with the error.
/// {@endtemplate}
class GraphQLResponseErrorLocation
    with AWSEquatable<GraphQLResponseErrorLocation>, AWSSerializable {
  /// The line in the GraphQL request document where the error-causing syntax
  /// element starts.
  final int line;

  /// The column in the GraphQL request document where the error-causing syntax
  /// element starts.
  final int column;

  /// {@macro graphql_response_error_location}
  const GraphQLResponseErrorLocation(this.line, this.column);

  @override
  List<Object?> get props => [line, column];

  factory GraphQLResponseErrorLocation.fromJson(Map<String, dynamic> json) {
    return GraphQLResponseErrorLocation(
      json['line'] as int,
      json['column'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'line': line,
        'column': column,
      };
}
