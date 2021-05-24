import 'package:ftauth_jwt/src/alg.dart';

class TestCase {
  final Algorithm algorithm;
  final String privateJwk;
  final String publicJwk;
  final String jwt;

  const TestCase(
    this.algorithm,
    this.privateJwk,
    this.publicJwk,
    this.jwt,
  );
}
