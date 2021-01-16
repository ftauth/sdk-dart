import 'dart:typed_data';

abstract class Signer {
  List<int> sign(List<int> bytes);
}
