import 'dart:async';
import 'dart:convert';

import 'package:amplify_appsync/src/config/appsync_config.dart';
import 'package:amplify_appsync/src/graphql/graphql_request.dart';
import 'package:amplify_appsync/src/ws/websocket_connection_header.dart';
import 'package:amplify_appsync/src/ws/websocket_message.dart';
import 'package:async/async.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'websocket_connection_payload.dart';
import 'websocket_message_stream_transformer.dart';

/// {@template websocket_connection}
/// Manages connection with an AppSync backend and subscription routing.
/// {@endtemplate}
class WebSocketConnection {
  static const webSocketProtocols = ['graphql-ws'];

  final AppSyncConfig _config;
  late final WebSocketChannel _channel;
  late final StreamSubscription<WebSocketMessage> _subscription;
  late final RestartableTimer _timeoutTimer;

  // Add connection error variable to throw in `init`.

  Future<void>? _initFuture;
  final Completer<void> _connectionReady = Completer<void>();

  /// Fires when the connection is ready to be listened to, i.e.
  /// after the first `connection_ack` message.
  Future<void> get ready => _connectionReady.future;

  /// Re-broadcasts messages for child streams.
  final StreamController<WebSocketMessage> _rebroadcastController =
      StreamController<WebSocketMessage>.broadcast();

  /// Incoming message stream for all events.
  Stream<WebSocketMessage> get _messageStream => _rebroadcastController.stream;

  /// {@macro websocket_connection}
  WebSocketConnection(this._config);

  /// Connects to the real time WebSocket.
  Future<void> _connect() async {
    final payload = WebSocketConnectionPayload.fromConfig(_config);

    final authorizationHeader = WebSocketConnectionHeader(_config);
    final connectionUri = _config.realTimeGraphQLUri.replace(
      queryParameters: <String, String>{
        'header': await authorizationHeader.encode(),
        'payload': payload.encode(),
      },
    );
    _channel = WebSocketChannel.connect(
      connectionUri,
      protocols: webSocketProtocols,
    );
    _subscription = _channel.stream
        .transform(const WebSocketMessageStreamTransformer())
        .listen(_onData);
  }

  /// Closes the WebSocket connection.
  void close() {
    _subscription.cancel();
    _channel.sink.close();
  }

  /// Initializes the connection.
  Future<void> init() {
    return _initFuture ??= _init();
  }

  Future<void> _init() async {
    await _connect();
    if (_connectionReady.isCompleted) return;
    send(MessageType.connectionInit);
    return ready;
  }

  /// Subscribes to the given GraphQL request. Returns the subscription object,
  /// or throws an [Exception] if there's an error.
  Stream<SubscriptionDataPayload> subscribe(
    GraphQLRequest request,
  ) {
    final subRegistration = WebSocketMessage(
      messageType: MessageType.start,
      payload: SubscriptionRegistrationPayload(
        request: request,
        config: _config,
      ),
    );
    final subscriptionId = subRegistration.id!;
    return _messageStream
        .where((msg) => msg.id == subscriptionId)
        .transform(const WebSocketSubscriptionStreamTransformer())
        .asBroadcastStream(
          onListen: (_) => _send(subRegistration),
          onCancel: (_) => _cancel(subscriptionId),
        );
  }

  /// Cancels a subscription.
  void _cancel(String subscriptionId) {
    _send(WebSocketMessage(
      id: subscriptionId,
      messageType: MessageType.stop,
    ));
  }

  /// Sends a structured message over the WebSocket.
  void send(MessageType type, {WebSocketMessagePayload? payload}) {
    final message = WebSocketMessage(messageType: type, payload: payload);
    _send(message);
  }

  /// Sends a structured message over the WebSocket.
  void _send(WebSocketMessage message) {
    final msgJson = json.encode(message.toJson());
    // print('Sent: $msgJson');
    _channel.sink.add(msgJson);
  }

  /// Times out the connection (usually if a keep alive has not been received in time).
  void _timeout(Duration timeoutDuration) {
    _rebroadcastController.addError(
      TimeoutException(
        'Connection timeout',
        timeoutDuration,
      ),
    );
  }

  /// Handles incoming data on the WebSocket.
  void _onData(WebSocketMessage message) {
    // print('Received: $message');
    switch (message.messageType) {
      case MessageType.connectionAck:
        final messageAck = message.payload as ConnectionAckMessagePayload;
        final timeoutDuration = Duration(
          milliseconds: messageAck.connectionTimeoutMs,
        );
        _timeoutTimer = RestartableTimer(
          timeoutDuration,
          () => _timeout(timeoutDuration),
        );
        _connectionReady.complete();
        // print('Registered timer');
        return;
      case MessageType.connectionError:
        final wsError = message.payload as WebSocketError?;
        _connectionReady.completeError(
          wsError ??
              Exception(
                'An unknown error occurred while connecting to the WebSocket',
              ),
        );
        return;
      case MessageType.keepAlive:
        _timeoutTimer.reset();
        // print('Reset timer');
        return;
      case MessageType.error:
        // Only handle general messages, not subscription-specific ones
        if (message.id != null) {
          break;
        }
        final wsError = message.payload as WebSocketError;
        _rebroadcastController.addError(wsError);
        return;
      default:
        break;
    }

    // Re-broadcast unhandled messages
    _rebroadcastController.add(message);
  }
}
