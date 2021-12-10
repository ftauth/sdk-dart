/// {@template validator}
/// An abstract representation of a validator of input type [T].
/// {@endtemplate}
abstract class Validator<T extends Object> {
  /// {@macro validator}
  const Validator();

  /// Validates any input.
  const factory Validator.any() = _AnyValidator<T>;

  /// Validates inputs against [value] using [Object.==].
  const factory Validator.value(T value) = _ValueValidator<T>;

  /// Validates inputs against one of [values] using [Validator.validate].
  const factory Validator.oneOf(List<Validator<T>> values) = _OneOfValidator<T>;

  /// Validates inputs against all of [values] using [Validator.validate].
  const factory Validator.allOf(List<Validator<T>> values) = _AllOfValidator<T>;

  /// Validates inputs against a regular expression.
  const factory Validator.regExp(String pattern) = _RegExpValidator<T>;

  /// Validates [input].
  ///
  /// Throws a [ValidationException] if [input] is not valid.
  void validate(T input);
}

class _AnyValidator<T extends Object> extends Validator<T> {
  const _AnyValidator();

  @override
  void validate(T input) {
    // No-op
  }

  @override
  String toString() => '*';
}

class _ValueValidator<T extends Object> extends Validator<T> {
  final T value;

  const _ValueValidator(this.value);

  @override
  void validate(T input) {
    if (input != value) {
      throw ValidationException('Expected value: $value');
    }
  }

  @override
  String toString() {
    if (T == String) {
      return '"$value"';
    }
    return '$value';
  }
}

class _OneOfValidator<T extends Object> extends Validator<T> {
  final List<Validator<T>> values;

  const _OneOfValidator(this.values);

  @override
  void validate(T input) {
    if (!values.any((validator) {
      try {
        validator.validate(input);
        return true;
      } on ValidationException {
        return false;
      }
    })) {
      throw ValidationException('Expected one of: $values');
    }
  }

  @override
  String toString() => 'One of: $values';
}

class _AllOfValidator<T extends Object> extends Validator<T> {
  final List<Validator<T>> values;

  const _AllOfValidator(this.values);

  @override
  void validate(T input) {
    if (!values.every((validator) {
      try {
        validator.validate(input);
        return true;
      } on ValidationException {
        return false;
      }
    })) {
      throw ValidationException('Expected all of: $values');
    }
  }

  @override
  String toString() => 'All of: $values';
}

class _RegExpValidator<T extends Object> extends Validator<T> {
  final String pattern;

  const _RegExpValidator(this.pattern);

  @override
  void validate(T input) {
    if (!RegExp(pattern).hasMatch(input.toString())) {
      throw ValidationException(
        'Expected value matching pattern: $pattern',
      );
    }
  }

  @override
  String toString() => 'r"$pattern"';
}

/// Thrown when an invalid input is encountered by a [Validator].
class ValidationException implements Exception {
  static const defaultMessage = 'An unknown exception occurred';

  final String? message;

  const ValidationException([this.message = defaultMessage]);

  @override
  String toString() {
    return 'ValidationException: $message';
  }
}
