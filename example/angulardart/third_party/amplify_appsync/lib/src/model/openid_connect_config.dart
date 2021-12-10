import 'package:json_annotation/json_annotation.dart';

part 'openid_connect_config.g.dart';

@JsonSerializable(includeIfNull: false)
class OpenIDConnectConfig {
  final int? authTTL;
  final String? clientId;
  final int? iatTTL;
  final String issuer;

  const OpenIDConnectConfig({
    this.authTTL,
    this.clientId,
    this.iatTTL,
    required this.issuer,
  });

  factory OpenIDConnectConfig.fromJson(Map<String, dynamic> json) =>
      _$OpenIDConnectConfigFromJson(json);

  Map<String, dynamic> toJson() => _$OpenIDConnectConfigToJson(this);
}
