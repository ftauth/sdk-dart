import 'package:json_annotation/json_annotation.dart';

/// Default serializer.
const serialize = JsonSerializable(includeIfNull: false, explicitToJson: true);
