import 'dart:async';

import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';

/// A description of an [AWSSigV4Signer] configuration.
///
/// All requests made to AWS services must be processed in the precise way
/// that service expects. Since each service is different, this class provides
/// a way to override steps of the signing process which need precendence over
/// the [BaseServiceConfiguration].
@sealed
abstract class ServiceConfiguration {
  final bool normalizePath;
  final bool omitSessionToken;

  const ServiceConfiguration._({
    bool? normalizePath,
    bool? omitSessionToken,
  })  : normalizePath = normalizePath ?? true,
        omitSessionToken = omitSessionToken ?? false;

  /// Applies service-specific keys to [base] with values from [canonicalRequest]
  /// and [credentials].
  @mustCallSuper
  void apply(
    Map<String, String> base,
    CanonicalRequest canonicalRequest, {
    required AWSCredentials credentials,
    required String payloadHash,
    required int contentLength,
  });

  /// Whether to include the body hash in the signing process.
  bool includeBodyHash(
    CanonicalRequest request,
    int contentLength,
  );

  /// Hashes the request payload for the canonical request.
  Future<String> hashPayload(AWSBaseHttpRequest request);

  /// Hashes the request payload for the canonical request synchronously.
  String hashPayloadSync(AWSBaseHttpRequest request);

  /// Transforms the request body using the [signingKey] and [seedSignature].
  Stream<List<int>> signBody({
    required AWSAlgorithm algorithm,
    required int contentLength,
    required List<int> signingKey,
    required String seedSignature,
    required AWSCredentialScope credentialScope,
    required CanonicalRequest canonicalRequest,
  });
}

class BaseServiceConfiguration extends ServiceConfiguration {
  const BaseServiceConfiguration({
    bool? normalizePath,
    bool? omitSessionToken,
  }) : super._(
          normalizePath: normalizePath,
          omitSessionToken: omitSessionToken,
        );

  @override
  void apply(
    Map<String, String> base,
    CanonicalRequest canonicalRequest, {
    required AWSCredentials credentials,
    required String payloadHash,
    required int contentLength,
  }) {
    final request = canonicalRequest.request;
    final presignedUrl = canonicalRequest.presignedUrl;
    final credentialScope = canonicalRequest.credentialScope;
    final algorithm = canonicalRequest.algorithm;
    final expiresIn = canonicalRequest.expiresIn;
    final omitSessionTokenFromSigning =
        canonicalRequest.omitSessionTokenFromSigning;

    base.addAll({
      if (!request.headers.containsKey(AWSHeaders.host))
        AWSHeaders.host: request.host,
      AWSHeaders.date: credentialScope.dateTime.formatFull(),
      if (presignedUrl)
        AWSHeaders.signedHeaders: canonicalRequest.signedHeaders.toString(),
      if (presignedUrl && algorithm != null) AWSHeaders.algorithm: algorithm.id,
      if (presignedUrl)
        AWSHeaders.credential: '${credentials.accessKeyId}/$credentialScope',
      if (presignedUrl && expiresIn != null)
        AWSHeaders.expires: expiresIn.toString(),
      if (includeBodyHash(canonicalRequest, contentLength))
        AWSHeaders.contentSHA256: canonicalRequest.payloadHash,
      if (credentials.sessionToken != null && !omitSessionTokenFromSigning)
        AWSHeaders.securityToken: credentials.sessionToken!,
    });
  }

  @override
  bool includeBodyHash(
    CanonicalRequest request,
    int contentLength,
  ) {
    return !request.presignedUrl && contentLength > 0;
  }

  @override
  Future<String> hashPayload(AWSBaseHttpRequest request) async {
    if (request is AWSStreamedHttpRequest) {
      final payload = await ByteStream(request.split()).toBytes();
      return payloadEncoder.convert(payload);
    }
    return hashPayloadSync(request);
  }

  @override
  String hashPayloadSync(AWSBaseHttpRequest request) {
    if (request is! AWSHttpRequest) {
      throw ArgumentError('Streaming requests cannot be hashed synchronously.');
    }
    return payloadEncoder.convert(request.bodyBytes);
  }

  @override
  Stream<List<int>> signBody({
    required AWSAlgorithm algorithm,
    required int contentLength,
    required List<int> signingKey,
    required String seedSignature,
    required AWSCredentialScope credentialScope,
    required CanonicalRequest canonicalRequest,
  }) {
    // By default, the body is not signed.
    return canonicalRequest.request.body;
  }
}
