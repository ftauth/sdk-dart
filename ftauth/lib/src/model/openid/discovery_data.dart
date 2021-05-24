import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'discovery_data.g.dart';

/// Response data from an OIDC discovery endpoint call.
///
/// See: https://openid.net/specs/openid-connect-discovery-1_0.html
@JsonSerializable(
  createToJson: false,
  fieldRename: FieldRename.snake,
)
class OpenIDDiscoveryData extends Equatable {
  final String issuer;
  final String authorizationEndpoint;
  final String tokenEndpoint;

  @JsonKey(name: 'userinfo_endpoint')
  final String? userInfoEndpoint;
  final String jwksUri;
  final String registrationEndpoint;
  final List<String>? scopesSupported;
  final List<String>? responseTypesSupported;
  final List<String>? responseModesSupported;
  final List<String>? grantTypesSupported;
  final List<String>? acrValuesSupported;
  final List<String> subjectTypesSupported;
  final List<String> idTokenSigningAlgValuesSupported;
  final List<String>? idTokenEncryptionAlgValuesSupported;
  final List<String>? idTokenEncryptionEncValuesSupported;

  @JsonKey(name: 'userinfo_signing_alg_values_supported')
  final List<String>? userInfoSigningAlgValuesSupported;

  @JsonKey(name: 'userinfo_encryption_alg_values_supported')
  final List<String>? userInfoEncryptionAlgValuesSupported;

  @JsonKey(name: 'userinfo_encryption_enc_values_supported')
  final List<String>? userInfoEncryptionEnvValuesSupported;
  final List<String>? responseObjectSigningAlgValuesSupported;
  final List<String>? responseObjectEncryptionAlgValuesSupported;
  final List<String>? responseObjectEncryptionEncValuesSupported;
  final List<String>? tokenEndpointAuthMethodsSupported;
  final List<String>? tokenEndpointAuthSigningAlgValuesSupported;
  final List<String>? displayValuesSupported;
  final List<String>? claimTypesSupported;
  final List<String>? claimsSupported;
  final String? serviceDocumentation;
  final List<String>? claimsLocalesSupported;
  final List<String>? uiLocalesSupported;
  final bool? claimsParameterSupported;
  final bool? requestParameterSupported;
  final bool? requestUriParameterSupported;
  final bool? requireRequestUriRegistration;
  final String? opPolicyUri;
  final String? opTosUri;

  const OpenIDDiscoveryData({
    required this.issuer,
    required this.authorizationEndpoint,
    required this.tokenEndpoint,
    this.userInfoEndpoint,
    required this.jwksUri,
    required this.registrationEndpoint,
    this.scopesSupported,
    this.responseTypesSupported,
    this.responseModesSupported,
    this.grantTypesSupported,
    this.acrValuesSupported,
    required this.subjectTypesSupported,
    required this.idTokenSigningAlgValuesSupported,
    this.idTokenEncryptionAlgValuesSupported,
    this.idTokenEncryptionEncValuesSupported,
    this.userInfoSigningAlgValuesSupported,
    this.userInfoEncryptionAlgValuesSupported,
    this.userInfoEncryptionEnvValuesSupported,
    this.responseObjectSigningAlgValuesSupported,
    this.responseObjectEncryptionAlgValuesSupported,
    this.responseObjectEncryptionEncValuesSupported,
    this.tokenEndpointAuthMethodsSupported,
    this.tokenEndpointAuthSigningAlgValuesSupported,
    this.displayValuesSupported,
    this.claimTypesSupported,
    this.claimsSupported,
    this.serviceDocumentation,
    this.claimsLocalesSupported,
    this.uiLocalesSupported,
    this.claimsParameterSupported,
    this.requestParameterSupported,
    this.requestUriParameterSupported,
    this.requireRequestUriRegistration,
    this.opPolicyUri,
    this.opTosUri,
  });

  factory OpenIDDiscoveryData.fromJson(Map<String, dynamic> json) =>
      _$OpenIDDiscoveryDataFromJson(json);

  @override
  List<Object?> get props => [
        issuer,
        authorizationEndpoint,
        tokenEndpoint,
        userInfoEndpoint,
        jwksUri,
        registrationEndpoint,
        scopesSupported,
        responseTypesSupported,
        responseModesSupported,
        grantTypesSupported,
        acrValuesSupported,
        subjectTypesSupported,
        idTokenSigningAlgValuesSupported,
        idTokenEncryptionAlgValuesSupported,
        idTokenEncryptionEncValuesSupported,
        userInfoSigningAlgValuesSupported,
        userInfoEncryptionAlgValuesSupported,
        userInfoEncryptionEnvValuesSupported,
        responseObjectSigningAlgValuesSupported,
        responseObjectEncryptionAlgValuesSupported,
        responseObjectEncryptionEncValuesSupported,
        tokenEndpointAuthMethodsSupported,
        tokenEndpointAuthSigningAlgValuesSupported,
        displayValuesSupported,
        claimTypesSupported,
        claimsSupported,
        serviceDocumentation,
        claimsLocalesSupported,
        uiLocalesSupported,
        claimsParameterSupported,
        requestParameterSupported,
        requestUriParameterSupported,
        requireRequestUriRegistration,
        opPolicyUri,
        opTosUri,
      ];
}
