import 'dart:convert';

import 'package:ftauth/src/model/model.dart';
import 'package:http/http.dart' as http;

import 'discovery_repo.dart';

class DiscoveryRepoImpl extends DiscoveryRepo {
  final Config _config;
  final http.Client _httpClient;

  DiscoveryRepoImpl(
    this._config, {
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  @override
  Future<OpenIDDiscoveryData?> retrieveOIDCData() async {
    final openidUrl = _config.gatewayUri.replace(
      pathSegments: [
        ..._config.gatewayUri.pathSegments,
        '.well-known',
        'openid-configuration',
      ],
    );
    final resp = await _httpClient.get(openidUrl);
    if (resp.statusCode == 404) {
      return null;
    } else if (resp.statusCode != 200) {
      throw ApiException.get(openidUrl, resp.statusCode, resp.body);
    }
    return OpenIDDiscoveryData.fromJson(
      jsonDecode(resp.body) as Map<String, dynamic>,
    );
  }
}
