import 'dart:typed_data';

import 'package:ftauth/src/storage/storage_repo_impl.dart';
import 'package:hive/hive.dart';

import 'authorizer/authorizer.dart'
    if (dart.library.io) 'authorizer/authorizer_io.dart'
    if (dart.library.html) 'authorizer/authorizer_html.dart';
import 'path_provider/path_provider.dart'
    if (dart.library.io) 'path_provider/path_provider_io.dart'
    if (dart.library.html) 'path_provider/path_provider_html.dart';

class FTAuth {
  static final instance = FTAuth._();
  final storageRepo = StorageRepoImpl();
  final _pathProvider = PathProvider();

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

  Future<void> init({Uint8List? encryptionKey}) async {
    final hivePath = _pathProvider.getHiveDirectory();
    if (hivePath != null) {
      Hive.init(hivePath);
    }
    _authorizer = AuthorizerImpl();
    await storageRepo.init(encryptionKey: encryptionKey);
  }
}
