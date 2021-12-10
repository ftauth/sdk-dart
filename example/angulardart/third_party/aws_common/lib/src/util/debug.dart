bool get isDebugMode {
  var _isDebugMode = false;
  assert(() {
    _isDebugMode = true;
    return true;
  }());
  return _isDebugMode;
}
