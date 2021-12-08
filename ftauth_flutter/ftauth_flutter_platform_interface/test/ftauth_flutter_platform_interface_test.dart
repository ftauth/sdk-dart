import 'package:flutter_test/flutter_test.dart';
import 'package:ftauth_flutter_platform_interface/ftauth_flutter_platform_interface.dart';
import 'package:ftauth_flutter_platform_interface/src/method_channel_ftauth.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  group('FTAuthFlutterPlugin', () {
    test('MethodChannelFTAuthFlutter is the default instance', () {
      expect(FTAuthPlatform.instance, isA<MethodChannelFTAuth>());
    });

    test('Cannot be implemented with `implements`', () {
      expect(() {
        FTAuthPlatform.instance = ImplementsFTAuthFlutterPlugin();
      }, throwsA(isA<Error>()));
    });

    test('Can be extended', () {
      FTAuthPlatform.instance = ExtendsFTAuthFlutterPlugin();
    });

    test('Can be mocked with `implements`', () {
      FTAuthPlatform.instance = ImplementsWithIsMock();
    });
  });
}

class ImplementsWithIsMock extends Mock
    with MockPlatformInterfaceMixin
    implements FTAuthPlatform {}

class ImplementsFTAuthFlutterPlugin extends Mock implements FTAuthPlatform {}

class ExtendsFTAuthFlutterPlugin extends FTAuthPlatform {}
