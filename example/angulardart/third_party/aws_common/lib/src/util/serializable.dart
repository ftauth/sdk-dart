import 'package:json_annotation/json_annotation.dart';

import 'json.dart';

/// Global serialization options for AWS types.
const awsSerializable = JsonSerializable(
  fieldRename: FieldRename.pascal,
  includeIfNull: false,
  explicitToJson: true,
);

mixin AWSSerializable on Object {
  Map<String, dynamic> toJson();

  @override
  String toString() {
    return prettyPrintJson(this);
  }
}
