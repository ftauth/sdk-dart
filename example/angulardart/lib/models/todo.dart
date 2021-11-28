import 'package:aws_common/aws_common.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'todo.g.dart';

@JsonSerializable(
  constructor: 'internal',
)
class Todo with AWSSerializable {
  const Todo({
    String? id,
    required this.name,
    bool this.completed = false,
    this.owner,
  }) : _id = id;

  @protected
  const Todo.internal({
    required String id,
    required this.name,
    this.completed,
    required String this.owner,
  }) : _id = id;

  final String? _id;
  String get id => _id!;

  final String name;
  final bool? completed;
  final String? owner;

  factory Todo.fromJson(Map<String, Object?> json) => _$TodoFromJson(json);

  @override
  Map<String, Object?> toJson() => _$TodoToJson(this);
}
