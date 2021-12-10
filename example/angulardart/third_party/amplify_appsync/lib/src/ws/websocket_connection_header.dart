import 'dart:async';
import 'dart:convert';

import 'package:amplify_appsync/src/config/appsync_config.dart';
import 'package:equatable/equatable.dart';

class WebSocketConnectionHeader with EquatableMixin {
  final AppSyncConfig config;

  const WebSocketConnectionHeader(this.config);

  @override
  List<Object?> get props => [config];

  Future<String> encode() async =>
      base64.encode(json.encode(await toJson()).codeUnits);

  Future<Map<String, dynamic>> toJson() async =>
      config.authorization.connectionHeaders(config.connectionRequest);
}
