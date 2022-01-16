import 'dart:convert';
import 'dart:html';

import 'package:async/async.dart';
import 'package:ftauth/ftauth.dart';
import 'package:http/http.dart' as http;

bool get isDevMode {
  var enabled = false;
  assert(enabled = true);
  return enabled;
}

final currentUri =
    Uri.parse(window.location.href.replaceAll('127.0.0.1', 'localhost'));

final redirectUri = currentUri.replace(path: '/', fragment: '/auth');

enum Environment { dev, prod }

class AppConfig {
  final Environment env;
  final Config config;

  AppConfig(
    this.env,
    this.config,
  );

  factory AppConfig.dev() {
    return AppConfig(
      Environment.dev,
      Config(
        gatewayUri: Uri.parse('http://localhost:8000'),
        clientId: '3cf9a7ac-9198-469e-92a7-cc2f15d8b87d',
        clientType: ClientType.public,
        redirectUri: redirectUri,
      ),
    );
  }

  static Future<AppConfig> prod() async {
    final config = await FTAuth.retrieveDemoConfig(
      redirectUri: redirectUri,
      httpClient: MonitoringHttpClient(),
    );
    return AppConfig(
      Environment.prod,
      config,
    );
  }
}

/// An HTTP client which monitors requests and reports them to the parent iFrame.
class MonitoringHttpClient extends http.BaseClient {
  static final _base = http.Client();

  static String _reformatJson(String json) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(jsonDecode(json));
    } on FormatException {
      return json;
    }
  }

  static String formatHttpRequest(http.BaseRequest request) {
    final sb = StringBuffer();
    sb.writeln('${request.method} ${request.url} HTTP/1.1');
    for (var entry in request.headers.entries) {
      sb.writeln('${entry.key}: ${entry.value}');
    }
    if (request.method == 'POST') {
      sb.writeln();
      if (request is http.Request) {
        sb.writeln(_reformatJson(request.body));
      } else {
        sb.writeln('<streaming body>');
      }
    }
    return sb.toString();
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final message = formatHttpRequest(request);
    window.top?.postMessage(message, '*');
    final resp = await _base.send(request);
    final splitter = StreamSplitter(resp.stream);
    final body = await http.ByteStream(splitter.split()).bytesToString();
    window.top?.postMessage('Response:\n${_reformatJson(body)}'.trim(), '*');
    return http.StreamedResponse(
      splitter.split(),
      resp.statusCode,
      contentLength: resp.contentLength,
      request: resp.request,
      headers: resp.headers,
    );
  }
}
