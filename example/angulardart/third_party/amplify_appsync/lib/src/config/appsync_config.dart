import 'dart:convert';

import 'package:amplify_appsync/amplify_appsync.dart';
import 'package:amplify_common/amplify_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';

class AppSyncConfig {
  /// The GraphQL URI
  final Uri graphQLUri;

  /// The WebSocket URI
  final Uri realTimeGraphQLUri;

  /// The endpoint authorization.
  final ApiAuthorization authorization;

  AWSHttpRequest get connectionRequest => AWSHttpRequest(
        method: HttpMethod.post,
        host: graphQLUri.host,
        path: '/graphql/connect',
        headers: {
          AWSHeaders.accept.toLowerCase(): 'application/json, text/javascript',
          AWSHeaders.contentEncoding.toLowerCase(): 'amz-1.0',
          AWSHeaders.contentType.toLowerCase():
              'application/json; charset=UTF-8',
        },
        body: '{}'.codeUnits,
      );

  AWSHttpRequest subscriptionRequest(GraphQLRequest request) => AWSHttpRequest(
        method: HttpMethod.post,
        host: graphQLUri.host,
        path: '/graphql',
        headers: {
          AWSHeaders.accept.toLowerCase(): 'application/json, text/javascript',
          AWSHeaders.contentEncoding.toLowerCase(): 'amz-1.0',
          AWSHeaders.contentType.toLowerCase():
              'application/json; charset=UTF-8',
        },
        body: jsonEncode(request).codeUnits,
      );

  const AppSyncConfig({
    required this.graphQLUri,
    required this.realTimeGraphQLUri,
    required this.authorization,
  });

  factory AppSyncConfig.fromAmplifyConfig(
    AmplifyConfig amplifyConfig, {
    String? apiName,
    ApiAuthorization? authorization,
  }) {
    final appSyncPlugin = amplifyConfig.api?.awsPlugin;
    if (appSyncPlugin == null) {
      throw ArgumentError('No API registered for this config');
    }
    final AWSApiConfig? appSyncConfig =
        apiName == null ? appSyncPlugin.default$ : appSyncPlugin[apiName];
    if (appSyncConfig == null) {
      throw ArgumentError('Could not locate ${apiName ?? 'default'} API');
    }
    final authType = appSyncConfig.authorizationType;
    if (authType == APIAuthorizationType.apiKey) {
      ArgumentError.checkNotNull(appSyncConfig.apiKey);
      authorization ??= AppSyncApiKeyAuthorization(appSyncConfig.apiKey!);
    } else {
      ArgumentError.checkNotNull(
        authorization,
        'Authorization required for all but API_KEY',
      );
    }
    final Uri graphQLUri = Uri.parse(appSyncConfig.endpoint);
    final bool isCustomDomain = !graphQLUri.host.endsWith('amazonaws.com');
    final String realTimeGraphQLUrl = isCustomDomain
        ? appSyncConfig.endpoint
        : appSyncConfig.endpoint
            .replaceFirst('appsync-api', 'appsync-realtime-api');
    final Uri realTimeGraphQLUri = Uri.parse(realTimeGraphQLUrl).replace(
      scheme: 'wss',
      path: isCustomDomain ? '/graphql/realtime' : '/graphql',
    );

    return AppSyncConfig(
      graphQLUri: graphQLUri,
      realTimeGraphQLUri: realTimeGraphQLUri,
      authorization: authorization!,
    );
  }
}
