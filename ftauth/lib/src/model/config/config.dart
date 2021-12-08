import 'package:equatable/equatable.dart';
import 'package:ftauth/ftauth.dart';
import 'package:ftauth/src/repo/config_loader/config_loader.dart';
import 'package:json_annotation/json_annotation.dart';

part 'config.g.dart';

/// Configuration of an OAuth client, including identifiers and URLs needed
/// to connect to a running server instance.
@JsonSerializable(
  fieldRename: FieldRename.snake,
)
class Config extends Equatable {
  static final ConfigLoader _configLoader = ConfigLoader();

  final Provider provider;
  final Uri gatewayUrl;
  final Uri? _authorizationUri;
  final Uri? _tokenUri;
  final Uri? _userInfoUri;
  final Uri redirectUri;
  final String clientId;
  final String? clientSecret;
  final ClientType clientType;
  final List<String> scopes;
  final List<String>? grantTypes;
  final TokenFormat accessTokenFormat;
  final TokenFormat refreshTokenFormat;

  Config({
    this.provider = Provider.generic,
    required String gatewayUrl,
    required this.clientId,
    this.clientSecret,
    this.clientType = ClientType.public,
    this.scopes = const [],
    required String redirectUri,
    this.grantTypes,
    this.accessTokenFormat = TokenFormat.jwt,
    this.refreshTokenFormat = TokenFormat.custom,
    Uri? authorizationUri,
    Uri? tokenUri,
    Uri? userInfoUri,
  })  : assert(
          clientType == ClientType.public || clientSecret != null,
          'Client secret must be included for confidential clients.',
        ),
        gatewayUrl = Uri.parse(gatewayUrl),
        redirectUri = Uri.parse(redirectUri),
        _authorizationUri = authorizationUri,
        _tokenUri = tokenUri,
        _userInfoUri = userInfoUri;

  @override
  List<Object?> get props => [
        provider,
        gatewayUrl,
        clientId,
        clientSecret,
        clientType,
        scopes,
        redirectUri,
        grantTypes,
        accessTokenFormat,
        refreshTokenFormat,
        _authorizationUri,
        _tokenUri,
        _userInfoUri,
      ];

  Uri get authorizationUri {
    return _authorizationUri ??
        gatewayUrl.replace(
          pathSegments: [...gatewayUrl.pathSegments, 'authorize'],
        );
  }

  Uri get tokenUri {
    return _tokenUri ??
        gatewayUrl.replace(
          pathSegments: [...gatewayUrl.pathSegments, 'token'],
        );
  }

  Uri get userInfoUri {
    return _userInfoUri ??
        gatewayUrl.replace(
          pathSegments: [...gatewayUrl.pathSegments, 'userinfo'],
        );
  }

  factory Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);

  Map<String, Object?> toJson() => _$ConfigToJson(this);

  static Future<Config> fromFile(String filename) {
    return _configLoader.fromFile(filename);
  }

  static Future<Config> fromUrl(Uri uri) {
    return _configLoader.fromUrl(uri);
  }
}
