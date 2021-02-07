import 'dart:async';
import 'dart:typed_data';

import 'package:ftauth/src/demo/demo.dart';
import 'package:ftauth/src/storage/storage_repo.dart';
import 'package:hive/hive.dart';

import 'path_provider/path_provider.dart';
import 'authorizer/authorizer.dart';
import 'model/config/config.dart';

const _isDemo = bool.fromEnvironment('demo', defaultValue: false);

/// The main utility class. It is generally not necessary to work with this
/// class directly.
class FTAuthImpl {
  static final instance = FTAuthImpl._();
  late final FTAuthConfig _config;

  FTAuthImpl._();

  /// Initialize the FTAuth library.
  ///
  /// It is required to call either `init` for server and web applications or
  /// `initFlutter` for Flutter applications.
  Future<void> init(
    FTAuthConfig config, {
    Uint8List? encryptionKey,
    Authorizer? authorizer,
    StorageRepo? storageRepo,
  }) async {
    const pathProvider = PathProvider();

    // This will return null for Flutter mobile and Web, but calling `Hive.init`
    // is not required in these cases.
    final hivePath = pathProvider.getHiveDirectory();
    if (hivePath != null) {
      Hive.init(hivePath);
    }
    _config = config;
    if (_isDemo) {
      _config.authorizer = DemoAuthorizer();
    } else {
      _config.authorizer = authorizer ??
          Authorizer(
            _config,
            storageRepo: storageRepo ?? StorageRepo.instance,
          );
    }

    await (storageRepo ?? StorageRepo.instance)
        .init(encryptionKey: encryptionKey);
  }
}
