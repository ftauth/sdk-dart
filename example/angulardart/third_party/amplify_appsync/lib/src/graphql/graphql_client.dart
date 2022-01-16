import 'dart:convert';

import 'package:amplify_appsync/amplify_appsync.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:http/http.dart' as http;

class GraphQLClient {
  final AppSyncConfig _config;
  final http.Client _client;

  GraphQLClient({
    required AppSyncConfig config,
    http.Client? baseClient,
  })  : _config = config,
        _client = baseClient ?? http.Client();

  Future<GraphQLResponse> send(GraphQLRequest request) async {
    final auth = _config.authorization;
    final body = jsonEncode(request).codeUnits;
    final httpRequest = AWSHttpRequest(
      method: HttpMethod.post,
      host: _config.graphQLUri.authority,
      path: _config.graphQLUri.path,
      body: body,
    );
    final resp = await _client.post(
      _config.graphQLUri,
      headers: auth.requestHeaders(httpRequest),
      body: body,
    );
    final respJson = jsonDecode(resp.body) as Map;
    final data = (respJson['data'] as Map?)?.cast<String, dynamic>();
    final operationName = request.operationName;

    Map? operationData;
    if (data != null) {
      if (operationName != null) {
        operationData = data[operationName] as Map?;
      } else if (data.length == 1) {
        operationData = data[data.keys.single] as Map?;
      } else {
        operationData = data;
      }
    }
    final errors = (respJson['errors'] as List?)?.cast<Map>();
    return GraphQLResponse(
      data: data,
      errors: GraphQLResponseErrors(
        errors == null
            ? const []
            : errors
                .map((error) => GraphQLResponseError.fromJson(
                      error.cast<String, dynamic>(),
                    ))
                .toList(),
      ),
    );
  }
}
