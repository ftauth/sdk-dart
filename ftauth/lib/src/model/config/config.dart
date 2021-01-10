import 'dart:async';

import 'package:ftauth/src/model/model.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:ftauth/src/config_loader/config_loader.dart'
    if (dart.library.io) 'package:ftauth/src/config_loader/config_loader_io.dart'
    if (dart.library.html) 'package:ftauth/src/config_loader/config_loader_html.dart';

part 'config.g.dart';

@JsonSerializable(
  fieldRename: FieldRename.snake,
  createToJson: false,
)
class Config {
  static final ConfigLoader _configLoader = ConfigLoader();

  final Uri gatewayUrl;
  final String clientId;
  final String? clientSecret;
  final ClientType clientType;
  final List<String>? scopes;
  final Uri redirectUri;
  final List<String>? grantTypes;

  Config({
    required String gatewayUrl,
    required this.clientId,
    this.clientSecret,
    this.clientType = ClientType.public,
    this.scopes,
    required String redirectUri,
    this.grantTypes,
  })  : assert(
          clientType == ClientType.public || clientSecret != null,
          'Client secret must be included for confidential clients.',
        ),
        gatewayUrl = Uri.parse(gatewayUrl),
        redirectUri = Uri.parse(redirectUri);

  Uri get authorizationUri {
    return gatewayUrl.replace(
      pathSegments: [...gatewayUrl.pathSegments, 'authorize'],
    );
  }

  Uri get tokenUri {
    return gatewayUrl.replace(
      pathSegments: [...gatewayUrl.pathSegments, 'token'],
    );
  }

  factory Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);

  static Future<Config> fromFile(String filename) {
    return _configLoader.fromFile(filename);
  }

  static Future<Config> fromUrl(String url) {
    return _configLoader.fromUrl(url);
  }
}
