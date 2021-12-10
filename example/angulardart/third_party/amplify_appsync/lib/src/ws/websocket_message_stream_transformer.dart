import 'dart:async';
import 'dart:convert';

import 'package:amplify_appsync/src/ws/websocket_message.dart';

class WebSocketMessageStreamTransformer
    extends StreamTransformerBase<dynamic, WebSocketMessage> {
  const WebSocketMessageStreamTransformer();

  @override
  Stream<WebSocketMessage> bind(Stream<dynamic> stream) {
    return stream
        .cast<String>()
        .map<Map>((str) => json.decode(str) as Map)
        .map(WebSocketMessage.fromJson);
  }
}

class WebSocketSubscriptionStreamTransformer
    extends StreamTransformerBase<WebSocketMessage, SubscriptionDataPayload> {
  const WebSocketSubscriptionStreamTransformer();

  @override
  Stream<SubscriptionDataPayload> bind(Stream<WebSocketMessage> stream) async* {
    await for (var event in stream) {
      switch (event.messageType) {
        case MessageType.data:
          final payload = event.payload as SubscriptionDataPayload;
          yield payload;
          break;
        case MessageType.error:
          final error = event.payload as WebSocketError;
          throw error;
        case MessageType.complete:
          return;
      }
    }
  }
}
