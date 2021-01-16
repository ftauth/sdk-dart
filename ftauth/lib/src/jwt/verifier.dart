import 'token.dart';

abstract class Verifier {
  void verify(JsonWebToken token);
}
