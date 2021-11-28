// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Todo _$TodoFromJson(Map<String, dynamic> json) => Todo.internal(
      id: json['id'] as String,
      name: json['name'] as String,
      completed: json['completed'] as bool?,
      owner: json['owner'] as String,
    );

Map<String, dynamic> _$TodoToJson(Todo instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'completed': instance.completed,
      'owner': instance.owner,
    };
