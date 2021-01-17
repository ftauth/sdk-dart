import 'dart:convert';

import 'dart:typed_data';

var _byteMask = BigInt.from(0xff);
final negativeFlag = BigInt.from(0x80);

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

    final bytes = encodeBigInt(input);

    return base64RawUrl.encode(bytes);
  }

  /// Copied from https://github.com/bcgit/pc-dart/blob/master/lib/src/utils.dart
  ///
  /// Encode a BigInt into bytes using big-endian encoding.
  /// It encodes the integer to a minimal twos-compliment integer as defined by
  /// ASN.1
  static Uint8List encodeBigInt(BigInt number) {
    if (number == BigInt.zero) {
      return Uint8List.fromList([0]);
    }

    int needsPaddingByte;
    int rawSize;

    if (number > BigInt.zero) {
      rawSize = (number.bitLength + 7) >> 3;
      needsPaddingByte =
          ((number >> (rawSize - 1) * 8) & negativeFlag) == negativeFlag
              ? 1
              : 0;
    } else {
      needsPaddingByte = 0;
      rawSize = (number.bitLength + 8) >> 3;
    }

    final size = rawSize + needsPaddingByte;
    var result = Uint8List(size);
    for (var i = 0; i < rawSize; i++) {
      result[size - i - 1] = (number & _byteMask).toInt();
      number = number >> 8;
    }
    return result;
  }
}

class Base64UrlUintDecoder extends Converter<String?, BigInt?> {
  const Base64UrlUintDecoder();

  @override
  BigInt? convert(String? input) {
    if (input == null) {
      return null;
    }

    final decoded = base64RawUrl.decode(input);
    return decodeBigInt(decoded);
  }

  /// Copied from https://github.com/bcgit/pc-dart/blob/master/lib/src/utils.dart
  ///
  /// Decode a BigInt from bytes in big-endian encoding.
  /// Twos compliment.
  BigInt decodeBigInt(List<int> bytes) {
    var negative = bytes.isNotEmpty && bytes[0] & 0x80 == 0x80;

    BigInt result;

    if (bytes.length == 1) {
      result = BigInt.from(bytes[0]);
    } else {
      result = BigInt.zero;
      for (var i = 0; i < bytes.length; i++) {
        var item = bytes[bytes.length - i - 1];
        result |= (BigInt.from(item) << (8 * i));
      }
    }
    return result != BigInt.zero
        ? negative
            ? result.toSigned(result.bitLength)
            : result
        : BigInt.zero;
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
  return (dt.millisecondsSinceEpoch / 1000).truncate();
}

List<int>? symmetricKeyFromJson(String? json) {
  if (json == null) return null;
  return base64RawUrl.decode(json);
}

String? symmetricKeyToJson(List<int>? key) {
  if (key == null) return null;
  return base64RawUrl.encode(key);
}
