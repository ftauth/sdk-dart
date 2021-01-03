import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ftauth/ftauth.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'flutter_authorizer.dart';

extension FTAuthX on FTAuth {
  Future<void> initFlutter() async {
    await Hive.initFlutter();
    final secureStorage = const FlutterSecureStorage();
    var containsEncryptionKey = await secureStorage.containsKey(key: 'key');
    Uint8List encryptionKey;
    if (containsEncryptionKey) {
      final encodedKey = await secureStorage.read(key: 'key');
      encryptionKey = base64Decode(encodedKey);
    } else {
      encryptionKey = Hive.generateSecureKey();
      await secureStorage.write(
          key: 'key', value: base64UrlEncode(encryptionKey));
    }
    authorizer = FlutterAuthorizer();
    await storageRepo.init(encryptionKey: encryptionKey);
  }
}
