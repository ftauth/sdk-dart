// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_graphql_apis_output.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListGraphqlApisOutput _$ListGraphqlApisOutputFromJson(
        Map<String, dynamic> json) =>
    ListGraphqlApisOutput(
      graphqlApis: (json['graphqlApis'] as List<dynamic>?)
              ?.map((e) => GraphqlApi.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      nextToken: json['nextToken'] as String?,
    );

Map<String, dynamic> _$ListGraphqlApisOutputToJson(
    ListGraphqlApisOutput instance) {
  final val = <String, dynamic>{
    'graphqlApis': instance.graphqlApis,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('nextToken', instance.nextToken);
  return val;
}
