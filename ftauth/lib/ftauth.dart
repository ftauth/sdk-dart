/// FTAuth client-side library for Dart servers and web applications.
///
/// For Flutter apps, see [ftauth_flutter](https://pub.dev/packages/ftauth_flutter).
library ftauth;

export 'src/ftauth.dart';

export 'src/http/client.dart';
export 'src/authorizer/credentials.dart';
export 'src/logger/logger.dart';
export 'src/model/model.dart';

export 'src/authorizer/authorizer.dart';
// export 'src/demo/demo.dart';

export 'src/repo/crypto/crypto_repo.dart';
export 'src/repo/storage/storage_repo.dart';

// SSL Pinning
export 'src/repo/ssl/ssl_pinning_client.dart';
export 'src/repo/ssl/ssl_repo.dart';

export 'src/util/oauth.dart';
