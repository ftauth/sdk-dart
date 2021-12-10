import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:async/async.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:aws_signature_v4/src/configuration/service_header.dart';
import 'package:aws_signature_v4/src/configuration/validator.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

enum Encoding {
  none,
}

extension on Encoding {
  String get value => toString().split('.')[1];

  Codec<List<int>, List<int>> get encoding {
    switch (this) {
      case Encoding.none:
        return IdentityCodec();
    }
  }
}

class S3ServiceConfiguration extends BaseServiceConfiguration {
  // 8 KB is the minimum chunk size.
  static const int _minChunkSize = 8 * 1024;

  // 64 KB is the recommended chunk size.
  static const int _defaultChunkSize = 64 * 1024;

  static const _chunkedPayloadSeedHash = 'STREAMING-AWS4-HMAC-SHA256-PAYLOAD';
  static const _unsignedChunkedPayloadSeedHash = 'UNSIGNED-PAYLOAD';
  static final _sigSep = ';chunk-signature='.codeUnits;
  static final _sep = '\r\n'.codeUnits;

  final bool signPayload;
  final bool chunked;
  final int chunkSize;
  final Encoding encoding;

  S3ServiceConfiguration({
    this.signPayload = true,
    this.chunked = true,
    int chunkSize = _defaultChunkSize,
    this.encoding = Encoding.none,
  })  : chunkSize = max(chunkSize, _minChunkSize),
        super(
          normalizePath: true,
          omitSessionToken: false,
        );

  int _calculateContentLength(AWSBaseHttpRequest request, int decodedLength) {
    var chunkedLength = 0;
    var metadataLength = 0;
    var numChunks = (decodedLength / chunkSize).ceil() + 1;
    final hashLength = sha256.blockSize;
    for (var i = 0; i < numChunks; i++) {
      var chunkLength = min(decodedLength - chunkedLength, chunkSize);
      metadataLength += chunkLength.toRadixString(16).codeUnits.length +
          _sigSep.length +
          (2 * _sep.length) +
          hashLength;
      chunkedLength += chunkLength;
    }
    return decodedLength + metadataLength;
  }

  @override
  void apply(
    Map<String, String> base,
    CanonicalRequest canonicalRequest, {
    required AWSCredentials credentials,
    required String payloadHash,
    required int contentLength,
  }) {
    super.apply(
      base,
      canonicalRequest,
      credentials: credentials,
      payloadHash: payloadHash,
      contentLength: contentLength,
    );

    if (chunked) {
      // Raw size of the data to be sent, before compression and without metadata.
      base[AWSHeaders.decodedContentLength] = contentLength.toString();

      if (encoding == Encoding.none) {
        base[AWSHeaders.contentEncoding] = 'aws-chunked';
        base[AWSHeaders.contentLength] = _calculateContentLength(
          canonicalRequest.request,
          contentLength,
        ).toString();
      } else {
        base[AWSHeaders.contentEncoding] = 'aws-chunked,${encoding.value}';
      }
      // base[AWSHeaders.transferEncoding] = 'chunked';
    }

    if (signPayload) {
      base[AWSHeaders.contentSHA256] = payloadHash;
    } else {
      base[AWSHeaders.contentSHA256] = 'UNSIGNED-PAYLOAD';
    }
  }

  @override
  Future<String> hashPayload(AWSBaseHttpRequest request) async {
    if (!chunked) {
      return super.hashPayload(request);
    }
    return hashPayloadSync(request);
  }

  @override
  String hashPayloadSync(AWSBaseHttpRequest request) {
    if (!chunked) {
      return super.hashPayloadSync(request);
    }
    if (signPayload) {
      return _chunkedPayloadSeedHash;
    }
    return _unsignedChunkedPayloadSeedHash;
  }

  @override
  Stream<List<int>> signBody({
    required AWSAlgorithm algorithm,
    required int contentLength,
    required List<int> signingKey,
    required String seedSignature,
    required AWSCredentialScope credentialScope,
    required CanonicalRequest canonicalRequest,
  }) async* {
    if (!chunked) {
      yield* super.signBody(
        algorithm: algorithm,
        contentLength: contentLength,
        signingKey: signingKey,
        seedSignature: seedSignature,
        credentialScope: credentialScope,
        canonicalRequest: canonicalRequest,
      );
      return;
    }

    final reader = ChunkedStreamReader(
      encoding == Encoding.none
          ? canonicalRequest.request.body
          : canonicalRequest.request.body.transform(encoding.encoding.encoder),
    );
    final decodedLength = contentLength;
    var previousSignature = seedSignature;
    var chunkedLength = 0;
    while (true) {
      var size = min(decodedLength - chunkedLength, chunkSize);
      var chunk = await reader.readBytes(size);
      final sb = StringBuffer();
      sb.writeln('$algorithm-PAYLOAD');
      sb.writeln(credentialScope.dateTime);
      sb.writeln(credentialScope);
      sb.writeln(previousSignature);
      sb.writeln(emptyPayloadHash);
      sb.write(payloadEncoder.convert(chunk));
      final stringToSign = sb.toString();

      final chunkSignature = algorithm.sign(stringToSign, signingKey);
      final bytes = <int>[
        ...size.toRadixString(16).codeUnits,
        ..._sigSep,
        ...chunkSignature.codeUnits,
        ..._sep,
        ...chunk,
        ..._sep,
      ];
      yield bytes;

      previousSignature = chunkSignature;
      chunkedLength += size;

      if (size == 0) {
        break;
      }
    }
  }
}

class S3ServiceHeader extends ServiceHeader {
  const S3ServiceHeader._(
    String key,
    Validator<String> valueValidator,
  ) : super(key, valueValidator);

  static S3ServiceHeader asciiMetadata(String metadata) => S3ServiceHeader._(
        'x-amz-meta-ascii',
        Validator.regExp(r'^[\x00-\x7F]*$'),
      );

  static S3ServiceHeader nonAsciiMetadata(String metadata) => S3ServiceHeader._(
        'x-amz-meta-nonascii',
        Validator.any(),
      );

  static const contentSha256 = S3ServiceHeader._(
    AWSHeaders.contentSHA256,
    Validator.oneOf([
      Validator.value('UNSIGNED-PAYLOAD'),
      Validator.value('STREAMING-AWS4-HMAC-SHA256-PAYLOAD'),

      // TODO: Hex signature validator
      Validator.regExp(r'.*')
    ]),
  );
}
