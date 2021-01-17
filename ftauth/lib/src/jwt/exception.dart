class MissingParameterExeception implements Exception {
  final String parameterName;

  const MissingParameterExeception(this.parameterName);

  @override
  String toString() {
    return 'Missing parameter: $parameterName';
  }
}

class InvalidSignatureException implements Exception {
  const InvalidSignatureException();

  @override
  String toString() => 'Signature does not match key';
}
