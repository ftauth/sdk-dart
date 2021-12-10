// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_graphql_apis_input.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListGraphqlApisInput _$ListGraphqlApisInputFromJson(
        Map<String, dynamic> json) =>
    ListGraphqlApisInput(
      maxResults: json['maxResults'] as int?,
      nextToken: json['nextToken'] as String?,
    );

Map<String, dynamic> _$ListGraphqlApisInputToJson(
    ListGraphqlApisInput instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('maxResults', instance.maxResults);
  writeNotNull('nextToken', instance.nextToken);
  return val;
}
