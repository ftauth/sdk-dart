import 'package:test/test.dart';
import 'package:ftauth/src/path_provider/path_provider_io.dart';

void main() {
  group('PathProvider', () {
    final pathProvider = PathProvider();
    test('getHomeDirectory', () {
      final homeDir = pathProvider.getHomeDirectory();
      expect(homeDir, isNotNull);
    });

    test('getHiveDirectory', () {
      final hiveDir = pathProvider.getHiveDirectory();
      expect(hiveDir, isNotNull);
    });
  });
}
