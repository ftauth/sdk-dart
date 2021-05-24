import 'package:ftauth/src/model/model.dart';

abstract class DiscoveryRepo {
  /// Retrieves OIDC discovery data from an OIDC server. Returns null if the
  /// server is not configured for the OpenID discovery endpoint.
  Future<OpenIDDiscoveryData?> retrieveOIDCData();
}
