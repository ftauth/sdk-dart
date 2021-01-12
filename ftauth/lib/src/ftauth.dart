import 'dart:async';
import 'dart:typed_data';

import 'package:ftauth/src/model/state/auth_state.dart';
import 'package:ftauth/src/storage/storage_repo.dart';
import 'package:ftauth/src/storage/storage_repo_impl.dart';
import 'package:hive/hive.dart';

import 'path_provider/path_provider.dart';
import 'authorizer/authorizer.dart';
import 'model/config/config.dart';

/// The main utility class. It is generally not necessary to work with this
/// class directly.
class FTAuthImpl {
  static final instance = FTAuthImpl._();
  late final FTAuthConfig _config;

  FTAuthImpl._();

  /// Yields a stream of state objects representing the user's authenticated
  /// status.
  Stream<AuthState> get authStates => _config.authorizer.authStates;

  /// Initialize the FTAuth library.
  ///
  /// It is required to call either `init` for server and web applications or
  /// `initFlutter` for Flutter applications.
  Future<void> init(
    FTAuthConfig config, {
    Uint8List? encryptionKey,
    Authorizer? authorizer,
  }) async {
    const pathProvider = PathProvider();

    // This will return null for Flutter mobile and Web, but calling `Hive.init`
    // is not required in these cases.
    final hivePath = pathProvider.getHiveDirectory();
    if (hivePath != null) {
      Hive.init(hivePath);
    }
    _config = config;
    _config.authorizer = authorizer ?? AuthorizerImpl(_config);

    await StorageRepo.instance.init(encryptionKey: encryptionKey);
  }
}
