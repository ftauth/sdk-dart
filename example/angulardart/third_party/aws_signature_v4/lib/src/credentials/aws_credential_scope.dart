import 'package:aws_signature_v4/src/request/aws_date_time.dart';
import 'package:aws_signature_v4/src/signer/aws_signer.dart';

/// {@template aws_credential_scope}
/// The scope for a request.
/// {@endtemplate}
class AWSCredentialScope {
  /// The time of the request.
  final AWSDateTime dateTime;

  /// The region of the request.
  final String region;

  /// The AWS service receiving the request.
  final String service;

  /// {@macro aws_credential_scope}
  AWSCredentialScope({
    AWSDateTime? dateTime,
    required this.region,
    required this.service,
  }) : dateTime = dateTime ?? AWSDateTime.now();

  @override
  String toString() =>
      '${dateTime.formatDate()}/$region/$service/${AWSSigV4Signer.terminationString}';
}
