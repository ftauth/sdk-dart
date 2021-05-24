@TestOn('browser')

import 'package:ftauth/src/repo/path_provider/path_provider.dart';
import 'package:test/test.dart';

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
