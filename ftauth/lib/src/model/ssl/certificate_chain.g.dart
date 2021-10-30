// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'certificate_chain.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CertificateChain _$CertificateChainFromJson(Map<String, dynamic> json) =>
    CertificateChain(
      root: Certificate.fromJson(json['root'] as Map<String, dynamic>),
      intermediate:
          Certificate.fromJson(json['intermediate'] as Map<String, dynamic>),
      leaf: Certificate.fromJson(json['leaf'] as Map<String, dynamic>),
      host: json['host'] as String,
    );

Map<String, dynamic> _$CertificateChainToJson(CertificateChain instance) =>
    <String, dynamic>{
      'root': instance.root,
      'intermediate': instance.intermediate,
      'leaf': instance.leaf,
      'host': instance.host,
    };
