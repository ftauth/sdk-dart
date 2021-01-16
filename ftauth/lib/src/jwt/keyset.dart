import 'package:equatable/equatable.dart';

import 'key.dart';
import 'prefs.dart';

part 'keyset.g.dart';

@serialize
class JsonWebKeySet extends Equatable {
  final List<JsonWebKey> keys;

  JsonWebKeySet(this.keys);

  @override
  List<Object?> get props => [keys];

  factory JsonWebKeySet.fromJson(Map<String, dynamic> json) =>
      _$JsonWebKeySetFromJson(json);

  Map<String, dynamic> toJson() => _$JsonWebKeySetToJson(this);
}
