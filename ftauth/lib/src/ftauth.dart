import 'dart:async';
import 'dart:typed_data';

import 'package:ftauth/src/model/state/auth_state.dart';
import 'package:ftauth/src/storage/storage_repo_impl.dart';
import 'package:hive/hive.dart';

import 'authorizer/authorizer.dart';
import 'authorizer/authorizer_stub.dart'
    if (dart.library.io) 'authorizer/authorizer_io.dart'
    if (dart.library.html) 'authorizer/authorizer_html.dart';
import 'model/config/config.dart';
import 'model/user/user.dart';
import 'path_provider/path_provider.dart'
    if (dart.library.io) 'path_provider/path_provider_io.dart'
    if (dart.library.html) 'path_provider/path_provider_html.dart';

/// The main utility class. It is generally not necessary to work with this
/// class directly.
class FTAuth {
  static final instance = FTAuth._();
  final storageRepo = StorageRepoImpl();

  FTAuth._();

  Authorizer? _authorizer;
  Authorizer get authorizer {
    if (_authorizer == null) {
      throw AssertionError('Must call init or initFlutter first.');
    }
    return _authorizer!;
  }

  set authorizer(Authorizer authorizer) {
    _authorizer = authorizer;
  }

  final authStateController = StreamController<AuthState>.broadcast();

  /// Yields a stream of state objects representing the user's authenticated
  /// status.
  Stream<AuthState> get authStates => authStateController.stream;
}

/// Initialize the FTAuth library.
///
/// It is required to call either `init` for server and web applications or
/// `initFlutter` for Flutter applications.
Future<void> init(Config config, {Uint8List? encryptionKey}) async {
  const pathProvider = PathProvider();

  // This will return null for Web, but calling `Hive.init`
  // is not required in this case.
  final hivePath = pathProvider.getHiveDirectory();
  if (hivePath != null) {
    Hive.init(hivePath);
  }
  FTAuth.instance.authorizer = AuthorizerImpl(config);
  await FTAuth.instance.storageRepo.init(encryptionKey: encryptionKey);
}
