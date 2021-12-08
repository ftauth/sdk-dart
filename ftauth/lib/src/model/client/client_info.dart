import 'package:equatable/equatable.dart';
import 'package:ftauth/ftauth.dart';
import 'package:json_annotation/json_annotation.dart';

part 'client_info.g.dart';

/// Metadata about an FTAuth client.
@JsonSerializable(
  fieldRename: FieldRename.snake,
)
class ClientInfo extends Equatable {
  final String id;
  final String? name;
  final ClientType type;
  final String? secret;
  final DateTime? secretExpiresAt;
  final List<String> redirectUris;

  @JsonKey(ignore: true)
  final bool isDevClient;

  @JsonKey(fromJson: _scopesFromJson)
  final List<String> scopes;
  final String? jwksUri;
  final String? logoUri;
  final List<String> grantTypes;
  final int accessTokenLife;
  final int refreshTokenLife;
  final List<Provider> providers;

  ClientInfo({
    required this.id,
    this.name,
    required this.type,
    this.secret,
    this.secretExpiresAt,
    required this.redirectUris,
    required this.scopes,
    this.jwksUri,
    this.logoUri,
    required this.grantTypes,
    required this.accessTokenLife,
    required this.refreshTokenLife,
    this.providers = const [Provider.ftauth],
  }) : isDevClient = redirectUris.contains('localhost');

  static List<String> _scopesFromJson(dynamic json) {
    final scopes = <String>[];
    if (json is List) {
      for (var item in json) {
        if (item is String) {
          scopes.add(item);
        } else if (item is Map && item.containsKey('name')) {
          scopes.add(item['name']);
        }
      }
    }
    return scopes;
  }

  ClientInfo copyWith({
    String? id,
    String? name,
    ClientType? type,
    String? secret,
    DateTime? secretExpiresAt,
    List<String>? redirectUris,
    List<String>? scopes,
    String? jwksUri,
    String? logoUri,
    List<String>? grantTypes,
    int? accessTokenLife,
    int? refreshTokenLife,
    List<Provider>? providers,
  }) {
    return ClientInfo(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      secret: secret ?? this.secret,
      secretExpiresAt: secretExpiresAt ?? this.secretExpiresAt,
      redirectUris: redirectUris ?? this.redirectUris,
      scopes: scopes ?? this.scopes,
      jwksUri: jwksUri ?? this.jwksUri,
      logoUri: logoUri ?? this.logoUri,
      grantTypes: grantTypes ?? this.grantTypes,
      accessTokenLife: accessTokenLife ?? this.accessTokenLife,
      refreshTokenLife: refreshTokenLife ?? this.refreshTokenLife,
      providers: providers ?? this.providers,
    );
  }

  factory ClientInfo.fromJson(Map<String, dynamic> json) =>
      _$ClientInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ClientInfoToJson(this);

  @override
  List<Object> get props => [
        id,
        if (name != null) name!,
        type,
        if (secret != null) secret!,
        if (secretExpiresAt != null) secretExpiresAt!,
        redirectUris,
        scopes,
        if (jwksUri != null) jwksUri!,
        if (logoUri != null) logoUri!,
        grantTypes,
      ];
}
