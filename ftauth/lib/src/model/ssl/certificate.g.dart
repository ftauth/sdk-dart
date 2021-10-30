// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'certificate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Certificate _$CertificateFromJson(Map<String, dynamic> json) => Certificate(
      host: json['host'] as String,
      certificate: json['certificate'] as String,
      type: $enumDecode(_$CertificateTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$CertificateToJson(Certificate instance) =>
    <String, dynamic>{
      'host': instance.host,
      'certificate': instance.certificate,
      'type': _$CertificateTypeEnumMap[instance.type],
    };

const _$CertificateTypeEnumMap = {
  CertificateType.leaf: 'leaf',
  CertificateType.intermediate: 'intermediate',
  CertificateType.root: 'root',
};
