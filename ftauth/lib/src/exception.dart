class UninitializedError extends Error {
  @override
  String toString() {
    return 'UninitializedError: Make sure to call `init` or `initFlutter` first.';
  }
}
