import 'package:json_annotation/json_annotation.dart';

part 'list_graphql_apis_input.g.dart';

@JsonSerializable(includeIfNull: false)
class ListGraphqlApisInput {
  // The maximum number of results you want the request to return.
  final int? maxResults;

  // An identifier that was returned from the previous call to this operation,
  // which can be used to return the next set of items in the list.
  final String? nextToken;

  const ListGraphqlApisInput({
    this.maxResults,
    this.nextToken,
  });

  factory ListGraphqlApisInput.fromJson(Map<String, dynamic> json) =>
      _$ListGraphqlApisInputFromJson(json);

  Map<String, dynamic> toJson() => _$ListGraphqlApisInputToJson(this);
}
