import 'package:flutter_driver/flutter_driver.dart';
import 'package:ftauth_example/keys.dart';
import 'package:test/test.dart';

import 'webview/webview_command.dart';
import 'webview/webview_command_result.dart';

void main() {
  group('SSO Module', () {
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) await driver.close();
    });

    final homeViewFinder = find.byValueKey(keyHomeScreen);
    final loginEmbeddedButtonFinder = find.byValueKey(keyLoginEmbeddedButton);
    final logoutButtonFinder = find.byValueKey(keyLogoutButton);
    final embeddedLoginViewFinder = find.byValueKey(keyEmbeddedLoginScreen);
    final authStateFinder = find.byValueKey(keyAuthStateText);

    test('Login', () async {
      await driver.waitFor(homeViewFinder);
      await driver.waitUntilNoTransientCallbacks();
      expect(await driver.getText(authStateFinder), 'Logged Out');
      await driver.tap(loginEmbeddedButtonFinder);
      await driver.waitFor(embeddedLoginViewFinder);

      // Execute the login flow
      final resultJson =
          await driver.sendCommand(WebViewCommand('dilloncp', '123456789*'));
      final result = WebViewCommandResult.fromJson(resultJson);
      if (!result.success) {
        fail(result.error);
      }

      // Expect a successful login
      await driver.waitFor(homeViewFinder);
      await driver.waitUntilNoTransientCallbacks();
      expect(await driver.getText(authStateFinder), 'Logged In');
    });

    test('Logout', () async {
      await driver.waitFor(homeViewFinder);
      await driver.tap(logoutButtonFinder);
      await driver.waitUntilNoTransientCallbacks();
      expect(await driver.getText(authStateFinder), 'Logged Out');
    });
  });
}
