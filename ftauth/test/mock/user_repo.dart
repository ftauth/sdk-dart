import 'dart:convert';

import 'package:ftauth/src/model/user/user.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';

class MockHttpClient extends MockClient {
  MockHttpClient() : super(handler);

  static Future<Response> handler(Request request) async {
    switch (request.url.path) {
      case '/user':
        final user = User(id: 'test');
        final json = jsonEncode(user.toJson());
        return Response(json, 200);
      default:
        return Response('Not found', 404);
    }
  }
}
