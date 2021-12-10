import 'package:collection/collection.dart';

mixin AWSEquatable<T extends AWSEquatable<T>> on Object {
  List<Object?> get props;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is T &&
          const DeepCollectionEquality.unordered().equals(props, other.props);

  @override
  int get hashCode => const DeepCollectionEquality.unordered().hash(props);
}
