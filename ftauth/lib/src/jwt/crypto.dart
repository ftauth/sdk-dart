abstract class Signer {
  Future<List<int>> sign(List<int> data);
}

abstract class Verifier {
  Future<void> verify(List<int> data, List<int> signature);
}
