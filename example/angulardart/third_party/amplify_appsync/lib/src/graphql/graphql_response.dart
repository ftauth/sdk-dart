import 'graphql_response_error.dart';

class GraphQLResponse {
  final Map<String, dynamic>? data;
  final GraphQLResponseErrors errors;

  const GraphQLResponse({
    required this.data,
    required this.errors,
  });
}
