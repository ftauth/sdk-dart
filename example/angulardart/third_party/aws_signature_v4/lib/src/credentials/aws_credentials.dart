import 'package:aws_common/aws_common.dart';
import 'package:json_annotation/json_annotation.dart';

part 'aws_credentials.g.dart';

/// A set of credentials used for accessing AWS services.
///
/// Temporary credentials must include an STS [sessionToken].
@JsonSerializable(fieldRename: FieldRename.snake)
class AWSCredentials with AWSEquatable<AWSCredentials>, AWSSerializable {
  final String accessKeyId;
  final String secretAccessKey;

  @JsonKey(name: 'token')
  final String? sessionToken;
  final DateTime? expiration;

  const AWSCredentials(
    this.accessKeyId,
    this.secretAccessKey, [
    this.sessionToken,
    this.expiration,
  ]);

  @override
  List<Object?> get props => [
        accessKeyId,
        secretAccessKey,
        sessionToken,
        expiration,
      ];

  factory AWSCredentials.fromJson(Map<String, dynamic> json) =>
      _$AWSCredentialsFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AWSCredentialsToJson(this);
}
