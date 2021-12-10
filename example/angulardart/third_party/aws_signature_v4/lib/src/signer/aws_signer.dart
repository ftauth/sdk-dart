import 'dart:async';

import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:aws_signature_v4/src/configuration/service_configuration.dart';
import 'package:aws_signature_v4/src/credentials/credentials_provider.dart';
import 'package:meta/meta.dart';

part 'zone.dart';

/// {@template aws_sig_v4_signer}
/// The main class for signing requests made to AWS services.
///
/// This signer supports the V4 signing process and, by default, uses
/// the `AWS4-HMAC-SHA256` signing algorithm.
/// {@endtemplate}
class AWSSigV4Signer {
  static const terminationString = 'aws4_request';

  final AWSAlgorithm algorithm;
  final AWSCredentialsProvider credentialsProvider;

  /// {@macro aws_sig_v4_signer}
  const AWSSigV4Signer({
    this.credentialsProvider = const AWSCredentialsProvider.dartEnvironment(),
    this.algorithm = AWSAlgorithm.hmacSha256,
  });

  /// Creates a presigned URL for the given [request].
  Future<Uri> presign(
    AWSHttpRequest request, {
    required AWSCredentialScope credentialScope,
    ServiceConfiguration serviceConfiguration =
        const BaseServiceConfiguration(),
    int? expiresIn,
  }) async {
    return _signZoned(() async {
      final credentials = await credentialsProvider.retrieve();
      final payloadHash = await serviceConfiguration.hashPayload(request);
      final contentLength = request.contentLength;
      return _sign(
        credentials,
        request,
        credentialScope: credentialScope,
        serviceConfiguration: serviceConfiguration,
        payloadHash: payloadHash,
        contentLength: contentLength,
        expiresIn: expiresIn,
        presignedUrl: true,
      ).uri;
    });
  }

  /// Creates a presigned URL synchronously for the given [request].
  Uri presignSync(
    AWSHttpRequest request, {
    required AWSCredentialScope credentialScope,
    ServiceConfiguration serviceConfiguration =
        const BaseServiceConfiguration(),
    int? expiresIn,
  }) {
    return _signZoned(() {
      final credentials = credentialsProvider.retrieve();
      if (credentials is! AWSCredentials) {
        throw ArgumentError('Must use presign');
      }
      final payloadHash = serviceConfiguration.hashPayloadSync(request);
      final contentLength = request.contentLength;
      return _sign(
        credentials,
        request,
        credentialScope: credentialScope,
        serviceConfiguration: serviceConfiguration,
        payloadHash: payloadHash,
        contentLength: contentLength,
        expiresIn: expiresIn,
        presignedUrl: true,
      ).uri;
    });
  }

  /// Signs the given [request] using authorization headers.
  Future<AWSSignedRequest> sign(
    AWSBaseHttpRequest request, {
    required AWSCredentialScope credentialScope,
    ServiceConfiguration serviceConfiguration =
        const BaseServiceConfiguration(),
  }) async {
    return _signZoned(() async {
      final credentials = await credentialsProvider.retrieve();
      final payloadHash = await serviceConfiguration.hashPayload(request);
      final contentLength = await request.contentLength;
      return _sign(
        credentials,
        request,
        credentialScope: credentialScope,
        serviceConfiguration: serviceConfiguration,
        payloadHash: payloadHash,
        contentLength: contentLength,
        presignedUrl: false,
      );
    });
  }

  /// Signs the given [request] synchronously using authorization headers.
  AWSSignedRequest signSync(
    AWSBaseHttpRequest request, {
    required AWSCredentialScope credentialScope,
    ServiceConfiguration serviceConfiguration =
        const BaseServiceConfiguration(),
  }) {
    return _signZoned(() {
      final credentials = credentialsProvider.retrieve();
      if (credentials is! AWSCredentials) {
        throw ArgumentError('Must use sign');
      }
      final contentLength = request.hasContentLength
          ? request.contentLength as int
          : throw ArgumentError('Must use sign');
      final payloadHash = serviceConfiguration.hashPayloadSync(request);
      return _sign(
        credentials,
        request,
        credentialScope: credentialScope,
        serviceConfiguration: serviceConfiguration,
        payloadHash: payloadHash,
        contentLength: contentLength,
        presignedUrl: false,
      );
    });
  }

  AWSSignedRequest _sign(
    AWSCredentials credentials,
    AWSBaseHttpRequest request, {
    required AWSCredentialScope credentialScope,
    required String payloadHash,
    required int contentLength,
    ServiceConfiguration serviceConfiguration =
        const BaseServiceConfiguration(),
    int? expiresIn,
    required bool presignedUrl,
  }) {
    final canonicalRequest = CanonicalRequest(
      request: request,
      credentials: credentials,
      credentialScope: credentialScope,
      payloadHash: payloadHash,
      contentLength: contentLength,
      presignedUrl: presignedUrl,
      algorithm: algorithm,
      expiresIn: expiresIn,
      configuration: serviceConfiguration,
    );
    final signingKey = algorithm.deriveSigningKey(
      credentials,
      credentialScope,
    );
    final sts = stringToSign(
      algorithm: algorithm,
      credentialScope: credentialScope,
      canonicalRequest: canonicalRequest,
    );
    final seedSignature = algorithm.sign(sts, signingKey);
    final signedBody = serviceConfiguration.signBody(
      algorithm: algorithm,
      contentLength: contentLength,
      signingKey: signingKey,
      seedSignature: seedSignature,
      credentialScope: credentialScope,
      canonicalRequest: canonicalRequest,
    );

    return _buildSignedRequest(
      credentials: credentials,
      credentialScope: credentialScope,
      signature: seedSignature,
      body: signedBody,
      contentLength: contentLength,
      canonicalRequest: canonicalRequest,
    );
  }

  /// Creates the string-to-sign (STS) for the canonical request.
  @visibleForTesting
  String stringToSign({
    required AWSAlgorithm algorithm,
    required AWSCredentialScope credentialScope,
    required CanonicalRequest canonicalRequest,
  }) {
    final sb = StringBuffer();
    sb.writeln(algorithm);
    sb.writeln(credentialScope.dateTime);
    sb.writeln(credentialScope);
    sb.write(canonicalRequest.hash);

    return sb.toString();
  }

  /// Creates an authorization header for a signed request.
  @visibleForTesting
  String createAuthorizationHeader({
    required AWSCredentials credentials,
    required AWSCredentialScope credentialScope,
    required SignedHeaders signedHeaders,
    required String signature,
  }) {
    return [
      algorithm.id,
      'Credential=${credentials.accessKeyId}/$credentialScope,',
      'SignedHeaders=$signedHeaders,',
      'Signature=$signature',
    ].join(' ');
  }

  /// Builds a signed request from [canonicalRequest] and [signature].
  AWSSignedRequest _buildSignedRequest({
    required AWSCredentials credentials,
    required CanonicalRequest canonicalRequest,
    required String signature,
    required Stream<List<int>> body,
    required int contentLength,
    required AWSCredentialScope credentialScope,
  }) {
    // The signing process requires component keys be encoded. However, the
    // actual HTTP request should have the pre-encoded keys.
    final queryParameters = Map.of(canonicalRequest.queryParameters);

    // Similar to query parameters, some header values are canonicalized for
    // signing. However their original values should be included in the
    // headers map of the HTTP request.
    final headers = Map.of(canonicalRequest.headers);

    // If the session token was omitted from signing, include it now.
    final sessionToken = credentials.sessionToken;
    final includeSessionToken =
        sessionToken != null && canonicalRequest.omitSessionTokenFromSigning;
    if (canonicalRequest.presignedUrl) {
      queryParameters[AWSHeaders.signature] = signature;
      if (includeSessionToken) {
        queryParameters[AWSHeaders.securityToken] = sessionToken!;
      }
    } else {
      headers[AWSHeaders.authorization] = createAuthorizationHeader(
        credentials: credentials,
        credentialScope: credentialScope,
        signedHeaders: canonicalRequest.signedHeaders,
        signature: signature,
      );
      if (includeSessionToken) {
        headers[AWSHeaders.securityToken] = sessionToken!;
      }
    }

    final originalRequest = canonicalRequest.request;
    return AWSSignedRequest(
      canonicalRequest: canonicalRequest,
      signature: signature,
      method: originalRequest.method,
      host: originalRequest.host,
      path: originalRequest.path,
      body: body,
      contentLength: contentLength,
      headers: headers,
      queryParameters: queryParameters,
    );
  }
}
