import 'package:equatable/equatable.dart';

import 'key.dart';
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

  JsonWebToken({
    String? raw,
    required this.header,
    required this.claims,
    List<int>? signature,
  })  : _raw = raw,
        _signature = signature {
    header.assertValid();
    claims.assertValid(header.type);
  }

  @override
  List<Object?> get props => [
        _raw,
        header,
        claims,
        signature,
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

  String encodeBase64(JsonWebKey privateKey) {
    final unsigned = encodeUnsigned();
    final signed = privateKey.sign(unsigned.codeUnits);

    final signature = base64RawUrl.encode(signed);
    _signature = signature.codeUnits;

    return _raw = '$unsigned.$signature';
  }

  String encodeUnsigned() {
    final header = this.header.encodeBase64();
    final payload = claims.encodeBase64();
    return '$header.$payload';
  }

  void verify(JsonWebKeySet keySet) {
    final key = keySet.keys.firstWhere(
      (key) => header.keyId != null && key.keyId == header.keyId,
      orElse: () => keySet.keys.first,
    );
    key.verify(this);
  }
}