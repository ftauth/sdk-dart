abstract class Signer {
  Future<List<int>> sign(List<int> bytes);
}

abstract class Verifier {
  Future<void> verify(List<int> bytes, List<int> expected);
}
