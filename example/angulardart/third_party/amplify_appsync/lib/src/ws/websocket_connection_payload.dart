import 'dart:convert';

import 'package:amplify_appsync/src/config/appsync_config.dart';
import 'package:equatable/equatable.dart';

class WebSocketConnectionPayload with EquatableMixin {
  const WebSocketConnectionPayload();

  factory WebSocketConnectionPayload.fromConfig(AppSyncConfig config) {
    return const WebSocketConnectionPayload();
  }

  @override
  List<Object?> get props => [];

  String encode() => base64.encode(utf8.encode(json.encode(this)));

  Map<String, dynamic> toJson() => <String, dynamic>{};
}
