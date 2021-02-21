import 'dart:convert';

import 'package:pointycastle/src/utils.dart';

Map<String, dynamic> decodeBase64(String base64) {
  final json = utf8.decode(base64RawUrl.decode(base64));
  return jsonDecode(json) as Map<String, dynamic>;
}

const base64RawUrl = Base64RawUrlCodec();
const base64UrlUint = Base64UrlUintCodec();

BigInt? base64UrlUintTryDecode(String? input) {
  try {
    return base64UrlUint.decode(input);
  } on FormatException {
    return null;
  }
}

String? base64UrlUintEncode(BigInt? input) => base64UrlUint.encode(input);
BigInt base64UrlUintDecode(String input) => base64UrlUint.decode(input)!;

class Base64UrlUintCodec extends Codec<BigInt?, String?> {
  const Base64UrlUintCodec();

  @override
  Converter<String?, BigInt?> get decoder => const Base64UrlUintDecoder();

  @override
  Converter<BigInt?, String?> get encoder => const Base64UrlUintEncoder();
}

class Base64UrlUintEncoder extends Converter<BigInt?, String?> {
  const Base64UrlUintEncoder();

  @override
  String? convert(BigInt? input) {
    if (input == null) {
      return null;
    }

    final bytes = encodeBigIntAsUnsigned(input);
    for (var i = 0; i < bytes.length; i++) {
      if (bytes[i] > 0) {
        return base64RawUrl.encode(bytes.sublist(i));
      }
    }

    return base64RawUrl.encode([0]);
  }
}

class Base64UrlUintDecoder extends Converter<String?, BigInt?> {
  const Base64UrlUintDecoder();

  @override
  BigInt? convert(String? input) {
    if (input == null || input == '') {
      return null;
    }

    final decoded = base64RawUrl.decode(input);
    return decodeBigIntWithSign(1, decoded);
  }
}

class Base64RawUrlCodec extends Codec<List<int>, String> {
  const Base64RawUrlCodec();

  @override
  Converter<String, List<int>> get decoder =>
      _StripPaddingDecoder().fuse(const Base64Decoder());

  @override
  Converter<List<int>, String> get encoder =>
      const Base64Encoder.urlSafe().fuse(_StripPaddingEncoder());
}

class _StripPaddingEncoder extends Converter<String, String> {
  const _StripPaddingEncoder();

  @override
  String convert(String input) {
    while (input.endsWith('=')) {
      input = input.substring(0, input.length - 1);
    }
    return input;
  }
}

class _StripPaddingDecoder extends Converter<String, String> {
  const _StripPaddingDecoder();

  @override
  String convert(String input) {
    final len = input.length;
    return input + '=' * ((4 - len % 4) % 4);
  }
}

DateTime? decodeDateTime(int? json) {
  if (json == null) return null;
  return DateTime.fromMillisecondsSinceEpoch(json * 1000);
}

int? encodeDateTime(DateTime? dt) {
  if (dt == null) return null;
  return dt.millisecondsSinceEpoch ~/ 1000;
}

List<int>? symmetricKeyFromJson(String? json) {
  if (json == null) return null;
  return base64RawUrl.decode(json);
}

String? symmetricKeyToJson(List<int>? key) {
  if (key == null) return null;
  return base64RawUrl.encode(key);
}
