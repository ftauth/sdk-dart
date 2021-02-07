import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:ftauth/ftauth.dart';
import 'package:ftauth/src/authorizer/authorizer.dart';
import 'package:ftauth/src/config_loader/config_loader.dart';
import 'package:ftauth/src/model/model.dart';
import 'package:ftauth/src/model/user/user.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

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
class FTAuthConfig extends http.BaseClient
    with EquatableMixin
    implements Authorizer {
  static final ConfigLoader _configLoader = ConfigLoader();

  final Uri gatewayUrl;
  final String clientId;
  final String? clientSecret;
  final ClientType clientType;
  final List<String> scopes;
  final Uri redirectUri;
  final List<String>? grantTypes;

  @JsonKey(ignore: true)
  late final Authorizer authorizer;

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

  @override
  @visibleForTesting
  Future<AuthState> init() {
    // ignore: invalid_use_of_visible_for_testing_member
    return authorizer.init();
  }

  @override
  Future<String> authorize() {
    return authorizer.authorize();
  }

  @override
  Future<Client> exchange(Map<String, String> parameters) {
    return authorizer.exchange(parameters);
  }

  @override
  @visibleForTesting
  Future<String> getAuthorizationUrl() {
    // ignore: invalid_use_of_visible_for_testing_member
    return authorizer.getAuthorizationUrl();
  }

  @override
  Future<void> logout() {
    return authorizer.logout();
  }

  /// Retrieves the stream of authorization states, representing the current
  /// state of the user's authorization.
  @override
  Stream<AuthState> get authStates => authorizer.authStates;

  /// Retrieves the current [User], if logged in, or `null`, if not.
  Future<User?> get currentUser async {
    final state = await authStates.first;
    if (state is AuthSignedIn) {
      return state.user;
    }
    return null;
  }

  /// Retrieves the current [Client] for this config, if logged in,
  /// or `null` if not.
  Future<Client?> get client async {
    final state = await authStates.first;
    if (state is AuthSignedIn) {
      return state.client;
    }
    return null;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final state = await authStates.first;
    if (state is AuthSignedIn) {
      return state.client.send(request);
    }
    throw AuthException('User not authenticated');
  }

  @override
  Future<Client> loginWithCredentials() {
    return authorizer.loginWithCredentials();
  }

  @override
  Future<Client> loginWithUsernameAndPassword(
      String username, String password) {
    return authorizer.loginWithUsernameAndPassword(username, password);
  }
}
