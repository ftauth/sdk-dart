import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:ftauth/ftauth.dart';
import 'package:ftauth/src/config_loader/config_loader.dart';
import 'package:ftauth/src/model/model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'config.g.dart';

const _defaultScopes = ['default'];

/// Configuration of an FTAuth client, including identifiers and URLs needed
/// to connect to a running FTAuth instance.
///
/// Most necessary functions are accesible via this object.
@JsonSerializable(
  fieldRename: FieldRename.snake,
  createToJson: false,
)
class FTAuthConfig with EquatableMixin {
  static final ConfigLoader _configLoader = ConfigLoader();

  final Uri gatewayUrl;
  final String clientId;
  final String? clientSecret;
  final ClientType clientType;
  final List<String> scopes;
  final Uri redirectUri;
  final List<String>? grantTypes;

  FTAuthConfig({
    required String gatewayUrl,
    required this.clientId,
    this.clientSecret,
    this.clientType = ClientType.public,
    this.scopes = _defaultScopes,
    required String redirectUri,
    this.grantTypes,
  })  : assert(
          clientType == ClientType.public || clientSecret != null,
          'Client secret must be included for confidential clients.',
        ),
        gatewayUrl = Uri.parse(gatewayUrl),
        redirectUri = Uri.parse(redirectUri);

  @override
  List<Object?> get props => [
        gatewayUrl,
        clientId,
        clientSecret,
        clientType,
        scopes,
        redirectUri,
        grantTypes,
      ];

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

  factory FTAuthConfig.fromJson(Map<String, dynamic> json) =>
      _$FTAuthConfigFromJson(json);

  static Future<FTAuthConfig> fromFile(String filename) {
    return _configLoader.fromFile(filename);
  }

  static Future<FTAuthConfig> fromUrl(String url) {
    return _configLoader.fromUrl(url);
  }
}
