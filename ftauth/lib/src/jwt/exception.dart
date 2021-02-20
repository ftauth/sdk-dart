class MissingParameterExeception implements Exception {
  final String parameterName;

  const MissingParameterExeception(this.parameterName);

  @override
  String toString() {
    return 'Missing parameter: $parameterName';
  }
}

class VerificationException implements Exception {
  const VerificationException();

  @override
  String toString() => 'Could not verify signature';
}
