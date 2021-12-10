import 'package:aws_common/aws_common.dart';
import 'package:meta/meta.dart';

@immutable
class GraphQLRequest<T extends AWSSerializable>
    with AWSSerializable, AWSEquatable<GraphQLRequest> {
  final String query;
  final Map<String, dynamic> variables;
  final String? operationName;
  final T? Function(Map<String, Object?>)? constructor;

  const GraphQLRequest(
    this.query, {
    this.variables = const <String, dynamic>{},
    this.operationName,
    this.constructor,
  });

  @override
  List<Object?> get props => [query, variables, operationName];

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'query': query,
        'variables': variables,
        if (operationName != null) 'operationName': operationName,
      };
}
