import 'authorizer/authorizer.dart';
import 'authorizer/authorizer_html.dart'
    if (dart.library.io) 'authorizer/authorizer_io.dart';

class FTAuth {
  static final instance = FTAuth._();

  FTAuth._();

  Authorizer? _authorizer;
  Authorizer get authorizer {
    if (_authorizer == null) {
      throw AssertionError('Must call init or initFlutter first.');
    }
    return _authorizer!;
  }

  set authorizer(Authorizer authorizer) {
    _authorizer = authorizer;
  }

  void init() {
    _authorizer = AuthorizerImpl();
  }
}
