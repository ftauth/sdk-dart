import 'package:ftauth/ftauth.dart';
import 'package:ftauth_jwt/ftauth_jwt.dart';
import 'package:http/http.dart' as http;

import 'metadata_repo_impl.dart';

abstract class MetadataRepo {
  factory MetadataRepo(
    Config config,
    http.Client client,
  ) {
    return MetadataRepoImpl(config, client);
  }

  Future<AuthorizationServerMetadata> loadServerMetadata({bool force});
  Future<AuthorizationServerMetadata> updateServerMetadata(
    AuthorizationServerMetadata metadata,
  );
  Future<JsonWebKeySet> loadKeySet();
}
