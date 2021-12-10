import 'dart:collection';

import 'package:amplify_common/src/config/config_map.dart';
import 'package:aws_common/aws_common.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

/// Global serialization options for Amplify types.
const amplifySerializable = JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
);

/// Serialization options for [ConfigMap] types.
@internal
const configMapSerializable = JsonSerializable(
  genericArgumentFactories: true,
  ignoreUnannotated: true,
  createToJson: false,
);

/// {@template amplify_common.serializable_map}
/// A [Map] which conforms to [AWSSerializable].
/// {@endtemplate}
class SerializableMap<V> extends MapView<String, V> with AWSSerializable {
  /// {@macro amplify_common.serializable_map}
  const SerializableMap(Map<String, V> map) : super(map);

  @override
  Map<String, Object?> toJson() => this;
}
