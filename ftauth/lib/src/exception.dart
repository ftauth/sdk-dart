class UninitializedError extends Error {
  UninitializedError() : super();

  @override
  String toString() {
    return 'UninitializedError: Make sure to call `init` or `initFlutter` first.';
  }
}
