// import 'package:ftauth/ftauth.dart';
// import 'package:ftauth/src/model/user/user.dart';
// import 'package:uuid/uuid.dart';

// final demoUser = User(
//   id: Uuid().v4(),
//   firstName: 'Demo',
//   lastName: 'User',
//   email: 'user@example.com',
//   phoneNumber: '8888888888',
//   provider: 'ftauth',
// );

// final mockClients = <String, ClientInfo>{
//   '9d4e7485-a581-4aa0-a140-16d86148d81f': ClientInfo(
//     clientId: '9d4e7485-a581-4aa0-a140-16d86148d81f',
//     clientName: 'Example.com',
//     clientType: ClientType.public,
//     redirectUris: ['https://example.com/auth'],
//     scopes: ['default'],
//     grantTypes: ['authorization_code', 'refresh_token'],
//   ),
//   '74fb2789-1abd-4094-8ecd-6fcf3ebc296f': ClientInfo(
//     clientId: '74fb2789-1abd-4094-8ecd-6fcf3ebc296f',
//     clientName: 'Example Server',
//     clientType: ClientType.confidential,
//     clientSecret: 'NzRmYjI3ODktMWFiZC00MDk0LThlY2QtNmZjZjNlYmMyOTZmCg==',
//     clientSecretExpiresAt: null,
//     redirectUris: ['https://example2.com/auth'],
//     scopes: ['default'],
//     grantTypes: ['client_credentials'],
//   ),
//   '623af44e-e59a-4daf-8ffe-91a40352fb4e': ClientInfo(
//     clientId: '623af44e-e59a-4daf-8ffe-91a40352fb4e',
//     clientType: ClientType.public,
//     clientName: 'ExampleApp',
//     redirectUris: ['exampleapp://auth'],
//     scopes: ['default'],
//     grantTypes: ['authorization_code', 'refresh_token'],
//   ),
// };
