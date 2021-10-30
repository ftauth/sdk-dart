// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discovery_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenIDDiscoveryData _$OpenIDDiscoveryDataFromJson(Map<String, dynamic> json) =>
    OpenIDDiscoveryData(
      issuer: json['issuer'] as String,
      authorizationEndpoint: json['authorization_endpoint'] as String,
      tokenEndpoint: json['token_endpoint'] as String,
      userInfoEndpoint: json['userinfo_endpoint'] as String?,
      jwksUri: json['jwks_uri'] as String,
      registrationEndpoint: json['registration_endpoint'] as String,
      scopesSupported: (json['scopes_supported'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      responseTypesSupported:
          (json['response_types_supported'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      responseModesSupported:
          (json['response_modes_supported'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      grantTypesSupported: (json['grant_types_supported'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      acrValuesSupported: (json['acr_values_supported'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      subjectTypesSupported: (json['subject_types_supported'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      idTokenSigningAlgValuesSupported:
          (json['id_token_signing_alg_values_supported'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      idTokenEncryptionAlgValuesSupported:
          (json['id_token_encryption_alg_values_supported'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      idTokenEncryptionEncValuesSupported:
          (json['id_token_encryption_enc_values_supported'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      userInfoSigningAlgValuesSupported:
          (json['userinfo_signing_alg_values_supported'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      userInfoEncryptionAlgValuesSupported:
          (json['userinfo_encryption_alg_values_supported'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      userInfoEncryptionEnvValuesSupported:
          (json['userinfo_encryption_enc_values_supported'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      responseObjectSigningAlgValuesSupported:
          (json['response_object_signing_alg_values_supported']
                  as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      responseObjectEncryptionAlgValuesSupported:
          (json['response_object_encryption_alg_values_supported']
                  as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      responseObjectEncryptionEncValuesSupported:
          (json['response_object_encryption_enc_values_supported']
                  as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      tokenEndpointAuthMethodsSupported:
          (json['token_endpoint_auth_methods_supported'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      tokenEndpointAuthSigningAlgValuesSupported:
          (json['token_endpoint_auth_signing_alg_values_supported']
                  as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      displayValuesSupported:
          (json['display_values_supported'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      claimTypesSupported: (json['claim_types_supported'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      claimsSupported: (json['claims_supported'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      serviceDocumentation: json['service_documentation'] as String?,
      claimsLocalesSupported:
          (json['claims_locales_supported'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      uiLocalesSupported: (json['ui_locales_supported'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      claimsParameterSupported: json['claims_parameter_supported'] as bool?,
      requestParameterSupported: json['request_parameter_supported'] as bool?,
      requestUriParameterSupported:
          json['request_uri_parameter_supported'] as bool?,
      requireRequestUriRegistration:
          json['require_request_uri_registration'] as bool?,
      opPolicyUri: json['op_policy_uri'] as String?,
      opTosUri: json['op_tos_uri'] as String?,
    );
