import 'dart:async';
// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:ftauth_flutter/ftauth_flutter.dart';

/// A web implementation of the FtauthFlutter plugin.
class FtauthFlutterWeb {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'ftauth_flutter',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = FtauthFlutterWeb();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  void _assert<T>(dynamic arg) {
    if (arg == null || arg is! T) {
      throw PlatformException(code: PlatformExceptionCodes.invalidArguments);
    }
  }

  /// Handles method calls over the MethodChannel of this plugin.
  /// Note: Check the "federated" architecture for a new way of doing this:
  /// https://flutter.dev/go/federated-plugins
  Future<dynamic> handleMethodCall(MethodCall call) async {
    if (call.method.startsWith('storage')) {
      return _handleStorageEvents(call);
    }

    switch (call.method) {
      case 'login':
        final url = call.arguments;
        _assert<String>(url);

        html.window.open(url, '_self');
        throw PlatformException(
          code: PlatformExceptionCodes.couldNotLaunchWebview,
          message: 'Could not launch webview',
        );

      // Future.wait([
      //   newWindow.on['unload'].first.then(
      //     (_) => throw PlatformException(code: 'CANCELLED'),
      //   ),
      //   newWindow.on
      // ]);

      // final message = await window.onMessage.first;

      // final origin = Uri.tryParse(message.origin)?.host;
      // final expected = Uri.tryParse(url)?.host;
      // if (origin == null || origin != expected) {
      //   throw 'Unknown origin';
      // }

      // final data = jsonDecode(message.data);
      // if (data is Map<String, dynamic>) {
      //   return data;
      // }

      // if (data['code'] == 'cancelled') {
      //   throw PlatformException(code: 'CANCELLED');
      // }
      default:
        throw PlatformException(
          code: PlatformExceptionCodes.unknown,
          details:
              'ftauth_flutter for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  String? _handleStorageEvents(MethodCall call) {
    switch (call.method) {
      case 'storageInit':
        // No-op
        break;
      case 'storageGet':
        final key = call.arguments;
        _assert<String>(key);
        return html.window.localStorage['ftauth.$key'];
      case 'storageSet':
        final kv = call.arguments;
        _assert<Map>(kv);
        final key = kv['key'];
        final val = kv['value'];
        _assert<String>(key);
        _assert<String>(val);
        html.window.localStorage['ftauth.$key'] = val;
        break;
      case 'storageDelete':
        final key = call.arguments;
        _assert<String>(key);
        html.window.localStorage.remove('ftauth.$key');
        break;
      case 'storageClear':
        html.window.localStorage
            .removeWhere((key, value) => key.startsWith('ftauth.'));
        break;
      default:
        throw PlatformException(
          code: PlatformExceptionCodes.unknown,
          details:
              'ftauth_flutter for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  /// Returns a [String] containing the version of the platform.
  Future<String> getPlatformVersion() {
    final version = html.window.navigator.userAgent;
    return Future.value(version);
  }
}
