import 'dart:async';

import 'package:aws_signature_v4/aws_signature_v4.dart';

/// A utility for retrieving AWS credentials at runtime.
abstract class AWSCredentialsProvider {
  const AWSCredentialsProvider._();

  /// Creates a [StaticCredentialsProvider] with the given [credentials].
  const factory AWSCredentialsProvider(AWSCredentials credentials) =
      StaticCredentialsProvider;

  /// Creates an [DartEnvironmentCredentialsProvider] for credentials injected via
  /// the Dart environment.
  const factory AWSCredentialsProvider.dartEnvironment() =
      DartEnvironmentCredentialsProvider;

  /// Retrieves AWS credentials.
  FutureOr<AWSCredentials> retrieve();
}

/// {@template aws_signature_v4.static_credentials_provider}
/// Creates a [AWSCredentialsProvider] for a set of static, compile-time AWS
/// credentials.
/// {@endtemplate}
class StaticCredentialsProvider extends AWSCredentialsProvider {
  /// {@macro aws_signature_v4.static_credentials_provider}
  const StaticCredentialsProvider(this._credentials) : super._();

  final AWSCredentials _credentials;

  @override
  AWSCredentials retrieve() => _credentials;
}

/// {@template aws_signature_v4.environment_credentials_provider}
/// Creates a [AWSCredentialsProvider] for a set of static, compile-time AWS
/// credentials from the Dart environment.
/// {@endtemplate}
class DartEnvironmentCredentialsProvider extends AWSCredentialsProvider {
  /// {@macro aws_signature_v4.environment_credentials_provider}
  const DartEnvironmentCredentialsProvider() : super._();

  @override
  AWSCredentials retrieve() {
    const accessKeyId = String.fromEnvironment('AWS_ACCESS_KEY_ID');
    const secretAccessKey = String.fromEnvironment('AWS_SECRET_ACCESS_KEY');
    const sessionToken = String.fromEnvironment('AWS_SESSION_TOKEN');

    if (accessKeyId.isEmpty || secretAccessKey.isEmpty) {
      throw Exception('Could not load credentials from environment');
    }

    return AWSCredentials(
      accessKeyId,
      secretAccessKey,
      sessionToken.isEmpty ? null : sessionToken,
    );
  }
}
