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

  factory JsonWebKeySet.fromJson(Map<String, Object?> json) {
    return JsonWebKeySet((json['keys'] as List<dynamic>)
        .map((e) {
          try {
            return JsonWebKey.fromJson(e as Map<String, Object?>);
          } on Exception {
            return null;
          }
        })
        .whereType<JsonWebKey>()
        .toList());
  }

  Map<String, Object?> toJson() => _$JsonWebKeySetToJson(this);
}
