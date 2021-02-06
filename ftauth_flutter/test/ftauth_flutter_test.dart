import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ftauth_flutter/ftauth_flutter.dart';

void main() {
  const MethodChannel channel = MethodChannel('ftauth_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FtauthFlutter.platformVersion, '42');
  });
}
