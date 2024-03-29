import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:meta/meta.dart';

import 'authorization_type.dart';

@immutable
abstract class ApiAuthorization {
  const ApiAuthorization._(this.type);

  final APIAuthorizationType type;
  Map<String, String> connectionHeaders(AWSHttpRequest request);
  Map<String, String> requestHeaders(AWSHttpRequest request);
}

class AppSyncApiKeyAuthorization extends ApiAuthorization {
  const AppSyncApiKeyAuthorization(this.apiKey)
      : super._(APIAuthorizationType.apiKey);

  final String apiKey;

  @override
  Map<String, String> connectionHeaders(AWSHttpRequest request) => {
        AWSHeaders.host.toLowerCase(): request.host,
        'x-api-key': apiKey,
      };

  @override
  Map<String, String> requestHeaders(AWSHttpRequest request) => {
        'x-api-key': apiKey,
      };

  @override
  bool operator ==(Object other) =>
      other is AppSyncApiKeyAuthorization && apiKey == other.apiKey;

  @override
  int get hashCode => apiKey.hashCode;
}

class AppSyncIamAuthorization extends ApiAuthorization {
  AppSyncIamAuthorization(AWSCredentialsProvider _credentials)
      : _signer = AWSSigV4Signer(credentialsProvider: _credentials),
        super._(APIAuthorizationType.iam);

  final AWSSigV4Signer _signer;

  @override
  Map<String, String> connectionHeaders(AWSHttpRequest request) =>
      _headers(request);

  @override
  Map<String, String> requestHeaders(AWSHttpRequest request) =>
      _headers(request);

  Map<String, String> _headers(AWSHttpRequest request) {
    final host = request.host;
    final region = host.split('.')[2];
    final credentialScope = AWSCredentialScope(
      region: region,
      service: 'appsync',
    );
    final signedRequest = _signer.signSync(
      request,
      credentialScope: credentialScope,
    );
    return signedRequest.headers;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSyncIamAuthorization && _signer == other._signer;

  @override
  int get hashCode => _signer.hashCode;
}

class AppSyncOidcAuthorization extends ApiAuthorization {
  const AppSyncOidcAuthorization(this.getCredentials)
      : super._(APIAuthorizationType.oidc);

  final String? Function() getCredentials;

  @override
  Map<String, String> connectionHeaders(AWSHttpRequest request) {
    final credentials = getCredentials();
    if (credentials == null) {
      throw Exception('Could not retrieve credentials');
    }
    return {
      'Authorization': credentials,
      'Host': request.host,
    };
  }

  @override
  Map<String, String> requestHeaders(AWSHttpRequest request) {
    final credentials = getCredentials();
    if (credentials == null) {
      throw Exception('Could not retrieve credentials');
    }
    return {
      'Authorization': credentials,
      'Host': request.host,
    };
  }
}
