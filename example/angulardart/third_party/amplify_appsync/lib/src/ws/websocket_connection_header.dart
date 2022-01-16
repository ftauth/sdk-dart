import 'dart:convert';

import 'package:amplify_appsync/src/config/appsync_config.dart';
import 'package:equatable/equatable.dart';

class WebSocketConnectionHeader with EquatableMixin {
  final AppSyncConfig config;

  const WebSocketConnectionHeader(this.config);

  @override
  List<Object?> get props => [config];

  String encode() => base64.encode(json.encode(toJson()).codeUnits);

  Map<String, dynamic> toJson() =>
      config.authorization.connectionHeaders(config.connectionRequest);
}
