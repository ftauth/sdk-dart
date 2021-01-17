abstract class Signer {
  Future<List<int>> sign(List<int> bytes);
}

abstract class Verifier {
  Future<void> verify(List<int> bytes, List<int> expected);
}

abstract class CryptoKey implements Verifier {}

abstract class PrivateKey extends CryptoKey implements Signer {
  PublicKey get publicKey;
}

abstract class PublicKey extends CryptoKey {}
