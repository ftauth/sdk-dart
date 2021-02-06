import 'dart:convert';
import 'dart:io';

import 'package:ftauth/ftauth.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'data.dart';

class DemoHttpClient extends MockClient {
  DemoHttpClient() : super(_handle);

  static Future<http.Response> _handle(http.Request request) async {
    switch (request.url.path) {
      case '/user':
        return http.Response(jsonEncode(demoUser.toJson()), 200);
      case '/api/admin/clients':
        return _handleClients(request);
      default:
        if (request.url.path.startsWith('/api/admin/client')) {
          final clientId = request.url.pathSegments.last;
          return _handleClient(request, clientId);
        }
        return http.Response('not found', 404);
    }
  }

  static Future<http.Response> _handleClients(http.Request request) async {
    switch (request.method) {
      case 'GET':
        return http.Response(jsonEncode(mockClients.values.toList()), HttpStatus.ok);
      case 'POST':
        try {
          final map = _deserializeJson(request.body);
          final newClient = ClientInfo.fromJson(map);
          if (!mockClients.containsKey(newClient.clientId)) {
            mockClients[newClient.clientId] = newClient;
          } else {
            return http.Response('client already exists', HttpStatus.badRequest);
          }
          return http.Response(jsonEncode(newClient.toJson()), HttpStatus.ok);
        } catch (e) {
          return http.Response(e.toString(), HttpStatus.internalServerError);
        }
      default:
        return http.Response('method not allowed', HttpStatus.methodNotAllowed);
    }
  }

  static Future<http.Response> _handleClient(http.Request request, String clientId) async {
    if (!mockClients.containsKey(clientId)) {
      return http.Response('client not found', HttpStatus.notFound);
    }
    switch (request.method) {
      case 'GET':
        final client = mockClients[clientId];
        return http.Response(jsonEncode(client), 200);
      case 'PUT':
        try {
          final map = _deserializeJson(request.body);
          final updatedClient = ClientInfo.fromJson(map);
          mockClients[clientId] = updatedClient;
          return http.Response(jsonEncode(updatedClient.toJson()), HttpStatus.ok);
        } catch (e) {
          return http.Response(e.toString(), HttpStatus.internalServerError);
        }
      case 'DELETE':
        mockClients.remove(clientId);
        return http.Response('', HttpStatus.ok);
      default:
        return http.Response('method not allowed', HttpStatus.methodNotAllowed);
    }
  }
}

Map<String, dynamic> _deserializeJson(String json) {
  return (jsonDecode(json) as Map).cast<String, dynamic>();
}
