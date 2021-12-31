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
  final Uri gatewayUri;
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
    this.provider = Provider.ftauth,
    required this.gatewayUri,
    required this.clientId,
    this.clientSecret,
    this.clientType = ClientType.public,
    this.scopes = const [],
    required this.redirectUri,
    this.grantTypes,
    this.accessTokenFormat = TokenFormat.jwt,
    this.refreshTokenFormat = TokenFormat.jwt,
    Uri? authorizationUri,
    Uri? tokenUri,
    Uri? userInfoUri,
  })  : assert(
          clientType == ClientType.public || clientSecret != null,
          'Client secret must be included for confidential clients.',
        ),
        _authorizationUri = authorizationUri,
        _tokenUri = tokenUri,
        _userInfoUri = userInfoUri;

  @override
  List<Object?> get props => [
        provider,
        gatewayUri,
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
        gatewayUri.replace(
          pathSegments: [...gatewayUri.pathSegments, 'authorize'],
        );
  }

  Uri get tokenUri {
    return _tokenUri ??
        gatewayUri.replace(
          pathSegments: [...gatewayUri.pathSegments, 'token'],
        );
  }

  Uri get userInfoUri {
    return _userInfoUri ??
        gatewayUri.replace(
          pathSegments: [...gatewayUri.pathSegments, 'userinfo'],
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

  Config copyWith({
    Provider? provider,
    Uri? gatewayUri,
    Uri? authorizationUri,
    Uri? tokenUri,
    Uri? userInfoUri,
    Uri? redirectUri,
    String? clientId,
    String? clientSecret,
    ClientType? clientType,
    List<String>? scopes,
    List<String>? grantTypes,
    TokenFormat? accessTokenFormat,
    TokenFormat? refreshTokenFormat,
  }) {
    return Config(
      provider: provider ?? this.provider,
      gatewayUri: gatewayUri ?? this.gatewayUri,
      clientId: clientId ?? this.clientId,
      clientSecret: clientSecret ?? this.clientSecret,
      clientType: clientType ?? this.clientType,
      scopes: scopes ?? this.scopes,
      redirectUri: redirectUri ?? this.redirectUri,
      grantTypes: grantTypes ?? this.grantTypes,
      accessTokenFormat: accessTokenFormat ?? this.accessTokenFormat,
      refreshTokenFormat: refreshTokenFormat ?? this.refreshTokenFormat,
      authorizationUri: authorizationUri ?? this.authorizationUri,
      userInfoUri: userInfoUri ?? this.userInfoUri,
      tokenUri: tokenUri ?? this.tokenUri,
    );
  }
}
