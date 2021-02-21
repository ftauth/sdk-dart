@TestOn('browser')

import 'package:test/test.dart';
import 'package:ftauth/src/path_provider/path_provider.dart';

void main() {
  group('PathProvider', () {
    final pathProvider = PathProvider();
    test('getHomeDirectory', () {
      final homeDir = pathProvider.getHomeDirectory();
      expect(homeDir, isNull);
    });

    test('getHiveDirectory', () {
      final hiveDir = pathProvider.getHiveDirectory();
      expect(hiveDir, isNull);
    });
  });
}
