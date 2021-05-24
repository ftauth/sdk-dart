@JS()
library crypto_subtle;

import 'dart:typed_data';
import 'package:js/js.dart';

@JS('CryptoKey')
class CryptoKey {
  external String get type;
  external bool get extractable;
  external RsaHashedKeyGenParams get algorithm;
  external List<String> get usages;
}

@JS()
@anonymous
class CryptoKeyPair {
  external CryptoKey get publicKey;
  external CryptoKey get privateKey;
}

@JS()
@anonymous
class RsaHashedKeyGenParams {
  external String get name;
  external int get modulusLength;
  external Uint8List get publicExponent;
  external String get hash;

  external factory RsaHashedKeyGenParams({
    String name,
    int modulusLength,
    Uint8List publicExponent,
    String hash,
  });
}

@JS()
@anonymous
class RsaPssParams {
  external String get name;
  external int get saltLength;

  external factory RsaPssParams({
    String name,
    int saltLength,
  });
}

/// Returns a Promise that fulfills with a newly-generated [CryptoKey],
/// for symmetrical algorithms, or a [CryptoKeyPair], containing two newly
/// generated keys, for asymmetrical algorithms. These will match the algorithm,
/// usages, and extractability given as parameters.
@JS('crypto.subtle.generateKey')
external Object generateKey(
  RsaHashedKeyGenParams params,
  bool extractable,
  List<String> keyUsages,
);

/// Returns a Promise that fulfills with a [CryptoKey] corresponding to the format,
/// the algorithm, raw key data, usages, and extractability given as parameters.
///
/// Valid `format` values:
/// - `raw`       Raw format
/// - `pkcs8`     PKCS #8
/// - `spki`      SubjetPublicKeyInfo format
/// - `jwk`       JSON Web Key
@JS('crypto.subtle.importKey')
external Object importKey(
  String format,
  Object jwk,
  RsaHashedKeyGenParams algorithm,
  bool extractable,
  List<String> keyUsages,
);

/// Returns a Promise that fulfills with a buffer containing the key in the requested format.
///
/// Valid `format` values:
/// - `raw`       Raw format
/// - `pkcs8`     PKCS #8
/// - `spki`      SubjetPublicKeyInfo format
/// - `jwk`       JSON Web Key
@JS('crypto.subtle.exportKey')
external Object exportKey(String format, CryptoKey key);

/// Returns a Promise that fulfills with the signature corresponding to the text,
/// algorithm, and key given as parameters.
@JS('crypto.subtle.sign')
external Object sign(
  String algorithm,
  CryptoKey privateKey,
  TypedData data,
);

/// Returns a Promise that fulfills with a Boolean value indicating if the
/// signature given as a parameter matches the text, algorithm, and key that
/// are also given as parameters.
@JS('crypto.subtle.verify')
external Object verify(
  String algorithm,
  CryptoKey publicKey,
  TypedData signature,
  TypedData data,
);

@JS('JSON.stringify')
external String stringify(Object object);
