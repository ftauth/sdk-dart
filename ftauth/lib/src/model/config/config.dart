import 'dart:html';

import 'package:ftauth/src/client.dart';
import 'package:ftauth/src/ftauth.dart';
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

  final String gatewayUrl;
  final String clientId;
  final String? clientSecret;
  final ClientType clientType;
  final List<String>? scopes;
  final String redirectUri;

  Config({
    required this.gatewayUrl,
    required this.clientId,
    this.clientSecret,
    this.clientType = ClientType.public,
    this.scopes,
    required this.redirectUri,
  }) : assert(
          clientType == ClientType.public || clientSecret != null,
          'Client secret must be included for confidential clients.',
        );

  factory Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);

  Future<Client> authorize() {
    return FTAuth.instance.authorizer.authorize(this);
  }

  static Future<Config> fromFile(String filename) {
    return _configLoader.fromFile(filename);
  }

  static Future<Config> fromUrl(String url) {
    return _configLoader.fromUrl(url);
  }
}
