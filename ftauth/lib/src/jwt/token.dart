import 'package:equatable/equatable.dart';
import 'package:ftauth/src/jwt/key.dart';

import 'crypto.dart';
import 'header.dart';
import 'claims.dart';
import 'util.dart';
import 'keyset.dart';

class JsonWebToken with EquatableMixin {
  String? _raw;
  String get raw {
    if (_raw != null) {
      return _raw!;
    }
    throw StateError('Must encode first');
  }

  final JsonWebHeader header;
  final JsonWebClaims claims;
  List<int>? _signature;
  List<int> get signature {
    if (_signature != null) {
      return _signature!;
    }
    throw StateError('Must encode first');
  }

  String get encodedSignature => base64RawUrl.encode(signature);

  JsonWebToken({
    String? raw,
    required this.header,
    required this.claims,
    List<int>? signature,
  }) : _signature = signature {
    header.assertValid();
    claims.assertValid(header.type);

    // Add the raw value if we can.
    if (_signature == null) {
      _raw = raw;
    } else {
      _raw = raw ?? '${encodeUnsigned()}.$encodedSignature';
    }
  }

  @override
  List<Object?> get props => [
        _raw,
        header,
        claims,
        _signature,
      ];

  factory JsonWebToken.parse(String json) {
    final parts = json.split('.');
    if (parts.length != 3) {
      throw FormatException('Invalid token');
    }

    final header = decodeBase64(parts[0]);
    final claims = decodeBase64(parts[1]);

    return JsonWebToken(
      raw: json,
      header: JsonWebHeader.fromJson(header),
      claims: JsonWebClaims.fromJson(claims),
      signature: base64RawUrl.decode(parts[2]),
    );
  }

  static JsonWebToken? tryParse(String json) {
    try {
      return JsonWebToken.parse(json);
    } catch (_) {
      return null;
    }
  }

  Future<String> encodeBase64(Signer privateKey) async {
    final unsigned = encodeUnsigned();
    _signature = await privateKey.sign(unsigned.codeUnits);

    return _raw = '$unsigned.$encodedSignature';
  }

  String encodeUnsigned() {
    final header = this.header.encodeBase64();
    final payload = claims.encodeBase64();
    return '$header.$payload';
  }

  Future<void> verify(
    JsonWebKeySet keySet, {
    required Verifier Function(JsonWebKey) verifierFactory,
  }) async {
    final key = keySet.keys.firstWhere(
      (key) => header.keyId != null && key.keyId == header.keyId,
      orElse: () => keySet.keys.first,
    );
    final verifier = verifierFactory(key);
    await verifier.verify(encodeUnsigned().codeUnits, signature);
  }
}
