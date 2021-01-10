import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake,
)
class User {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? provider;

  User({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.provider,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
