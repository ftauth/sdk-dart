import 'package:json_annotation/json_annotation.dart';

import 'graphql_apis.dart';

part 'list_graphql_apis_output.g.dart';

@JsonSerializable(includeIfNull: false)
class ListGraphqlApisOutput {
// The GraphqlApi objects.
  final List<GraphqlApi> graphqlApis;

  // An identifier to be passed in the next request to this operation to return
  // the next set of items in the list.
  final String? nextToken;

  const ListGraphqlApisOutput({
    this.graphqlApis = const [],
    this.nextToken,
  });

  factory ListGraphqlApisOutput.fromJson(Map<String, dynamic> json) =>
      _$ListGraphqlApisOutputFromJson(json);

  Map<String, dynamic> toJson() => _$ListGraphqlApisOutputToJson(this);
}
