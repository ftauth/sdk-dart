import 'package:ftauth/ftauth.dart';
import 'package:ftauth/src/jwt/keyset.dart';

abstract class MetadataRepo {
  Future<AuthorizationServerMetadata> loadServerMetadata({bool force});
  Future<AuthorizationServerMetadata> updateServerMetadata(
    AuthorizationServerMetadata metadata,
  );
  Future<JsonWebKeySet> loadKeySet();
}
