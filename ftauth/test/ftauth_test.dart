import 'package:ftauth/ftauth.dart';
import 'package:test/test.dart';

void main() {
  group('FTAuth', () {
    test('init', () async {
      final ftauth = FTAuth.instance;
      await ftauth.init();
    });
  });
}
