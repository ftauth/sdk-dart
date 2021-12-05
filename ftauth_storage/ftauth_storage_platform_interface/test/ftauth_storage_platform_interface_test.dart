import 'package:flutter_test/flutter_test.dart';
import 'package:ftauth_storage_platform_interface/ftauth_storage_platform_interface.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  group('$FTAuthStoragePlatform', () {
    test('$MethodChannelFTAuthStorage is the default instance', () {
      expect(FTAuthStoragePlatform.instance, isA<MethodChannelFTAuthStorage>());
    });

    test('Cannot be implemented with `implements`', () {
      expect(() {
        FTAuthStoragePlatform.instance = ImplementsFTAuthStoragePlatform();
      }, throwsA(isA<Error>()));
    });

    test('Can be extended', () {
      FTAuthStoragePlatform.instance = ExtendsFTAuthStoragePlatform();
    });

    test('Can be mocked with `implements`', () {
      FTAuthStoragePlatform.instance = ImplementsWithIsMock();
    });
  });
}

class ImplementsWithIsMock extends Mock
    with MockPlatformInterfaceMixin
    implements FTAuthStoragePlatform {}

class ImplementsFTAuthStoragePlatform extends Mock
    implements FTAuthStoragePlatform {}

class ExtendsFTAuthStoragePlatform extends FTAuthStoragePlatform {}
