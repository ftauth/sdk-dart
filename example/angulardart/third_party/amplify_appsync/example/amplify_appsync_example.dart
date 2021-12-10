import 'dart:convert';

import 'package:amplify_appsync/src/config/appsync_config.dart';
import 'package:amplify_appsync/src/graphql/graphql_request.dart';
import 'package:amplify_appsync/src/ws/websocket_connection.dart';
import 'package:amplify_common/amplify_common.dart';

import 'amplifyconfiguration.dart';

Future<void> main() async {
  final amplifyConfigMap = jsonDecode(amplifyconfig) as Map<String, dynamic>;
  final amplifyConfig = AmplifyConfig.fromJson(amplifyConfigMap);
  final appSyncConfig = AppSyncConfig.fromAmplifyConfig(amplifyConfig);
  final webSocketConnection = WebSocketConnection(appSyncConfig);
  await webSocketConnection.init();
  final stream = webSocketConnection.subscribe(const GraphQLRequest(
    '''
    subscription OnShopifyEvent {
      onCreateShopifyEvent {
        id
        type
        payload
      }
    }
    ''',
  ));
  try {
    await for (var payload in stream) {
      print('Got data: $payload');
    }
  } on Exception catch (e) {
    print('Got error: $e');
  }
}
