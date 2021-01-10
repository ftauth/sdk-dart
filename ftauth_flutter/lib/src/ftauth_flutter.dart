import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ftauth/ftauth.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'flutter_authorizer.dart';

Future<void> initFlutter(Config config) async {
  await Hive.initFlutter();
  Uint8List encryptionKey;
  if (!kIsWeb) {
    final secureStorage = const FlutterSecureStorage();
    var containsEncryptionKey = await secureStorage.containsKey(key: 'key');
    if (containsEncryptionKey) {
      final encodedKey = await secureStorage.read(key: 'key');
      encryptionKey = base64Decode(encodedKey);
    } else {
      encryptionKey = Hive.generateSecureKey();
      await secureStorage.write(
          key: 'key', value: base64UrlEncode(encryptionKey));
    }
  }
  FTAuth.instance.authorizer = FlutterAuthorizer(config);
  await FTAuth.instance.storageRepo.init(encryptionKey: encryptionKey);
}
