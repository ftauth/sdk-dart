/// FTAuth client-side library for Dart servers and web applications.
///
/// For Flutter apps, see [ftauth_flutter](https://pub.dev/packages/ftauth_flutter).
library ftauth;

import 'src/ftauth.dart';

export 'src/http/client.dart';
export 'src/credentials.dart';
export 'src/model/model.dart';

export 'src/authorizer/authorizer.dart';
export 'src/crypto/crypto_repo.dart';
export 'src/storage/storage_repo.dart';

final FTAuthImpl FTAuth = FTAuthImpl.instance;
