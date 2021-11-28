import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_driver/src/common/message.dart';
import 'package:ftauth_flutter/ftauth_flutter.dart';

import 'webview_command.dart';
import 'webview_command_result.dart';

class WebViewCommandExtension extends CommandExtension {
  @override
  Future<Result> call(
    Command command,
    WidgetController prober,
    CreateFinderFactory finderFactory,
    CommandHandlerFactory handlerFactory,
  ) async {
    final webViewCommand = command as WebViewCommand;

    final webViewState =
        prober.state(find.byType(EmbeddedLoginView)) as EmbeddedLoginViewState;

    final username = webViewCommand.username;
    final password = webViewCommand.password;

    await webViewState.loadedLoginPage.future;

    final webViewController = webViewState.controller;

    try {
      await webViewController.evaluateJavascript('''
    let usernameInput = document.getElementById('username');
    usernameInput.scrollIntoView();
    usernameInput.value = '$username';

    let passwordInput = document.getElementById('password');
    passwordInput.scrollIntoView();
    passwordInput.value = '$password';

    let loginButton = document.getElementsByClassName('sign-in').item(0);
    loginButton.scrollIntoView();
    loginButton.click();
    ''');
    } on Exception catch (e) {
      return WebViewCommandResult.error(e.toString());
    }

    final sso = prober.widget(find.byType(FTAuth)) as FTAuth;

    await for (final state in sso.client.authStates) {
      if (state is AuthSignedIn) {
        return WebViewCommandResult.success();
      } else if (state is AuthFailure) {
        return WebViewCommandResult.error(state.toString());
      }
    }

    return WebViewCommandResult.error('Unknown');
  }

  @override
  String get commandKind => 'WebViewCommand';

  @override
  Command deserialize(
    Map<String, String> params,
    DeserializeFinderFactory finderFactory,
    DeserializeCommandFactory commandFactory,
  ) {
    return WebViewCommand.deserialize(params);
  }
}
