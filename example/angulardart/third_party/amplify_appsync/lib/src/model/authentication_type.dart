import 'package:json_annotation/json_annotation.dart';

enum AuthenticationType {
  @JsonValue('API_KEY')
  apiKey,
  @JsonValue('AWS_IAM')
  awsIam,
  @JsonValue('AMAZON_COGNITO_USER_POOLS')
  cognitoUserPools,
  @JsonValue('OPENID_CONNECT')
  openIDConnect,
  @JsonValue('AWS_LAMBDA')
  awsLambda,
}
