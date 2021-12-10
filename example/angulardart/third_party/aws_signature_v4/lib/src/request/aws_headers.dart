/// Headers used in signed AWS requests.
abstract class AWSHeaders {
  const AWSHeaders._();

  static const accept = 'Accept';
  static const algorithm = 'X-Amz-Algorithm';
  static const authorization = 'Authorization';
  static const contentEncoding = 'Content-Encoding';
  static const contentLength = 'Content-Length';
  static const contentType = 'Content-Type';
  static const contentSHA256 = 'x-amz-content-sha256';
  static const credential = 'X-Amz-Credential';
  static const date = 'X-Amz-Date';
  static const decodedContentLength = 'X-Amz-Decoded-Content-Length';
  static const expires = 'X-Amz-Expires';
  static const host = 'Host';
  static const regionSet = 'X-Amz-Region-Set';
  static const securityToken = 'X-Amz-Security-Token';
  static const signature = 'X-Amz-Signature';
  static const signedHeaders = 'X-Amz-SignedHeaders';
  static const target = 'X-Amz-Target';
  static const transferEncoding = 'Transfer-Encoding';
}

/// Common header values used in AWS requests.
abstract class AWSHeaderValues {
  const AWSHeaderValues._();

  static const defaultContentType = 'application/x-amz-json-1.1';
}
