import 'package:ftauth/ftauth.dart';
import 'package:ftauth/src/metadata/metadata_repo.dart';

import 'authorizer.dart';

class AuthorizerImpl extends Authorizer {
  AuthorizerImpl(
    FTAuthConfig config, {
    StorageRepo? storageRepo,
    MetadataRepo? metadataRepo,
  }) : super(
          config,
          storageRepo: storageRepo,
          metadataRepo: metadataRepo,
        );

  @override
  Future<void> authorize() {
    throw UnimplementedError();
  }

  @override
  Future<void> launchUrl(String url) {
    throw UnimplementedError();
  }
}
