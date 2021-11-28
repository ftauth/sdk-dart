import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import 'package:ftauth/ftauth.dart';
import 'package:http/http.dart' as http;

import 'authorizer_base.dart';

class Authorizer extends AuthorizerBase {
  Authorizer(
    Config config, {
    required StorageRepo storageRepo,
    SSLRepo? sslRepository,
    http.Client? baseClient,
    Duration? timeout,
    Uint8List? encryptionKey,
    bool? clearOnFreshInstall,
  }) : super(
          config,
          storageRepo: storageRepo,
          sslRepository: sslRepository,
          baseClient: baseClient,
          timeout: timeout,
          encryptionKey: encryptionKey,
          clearOnFreshInstall: clearOnFreshInstall,
        );

  WindowBase? popupWindow;

  @override
  Future<AuthState> onFoundState({
    required String state,
    required String codeVerifier,
  }) async {
    final location = Uri.parse(window.location.href);
    final parameters = location.queryParameters;

    // If this is a redirect, handle it.
    if (parameters.containsKey('code') && parameters.containsKey('state') ||
        parameters.containsKey('error')) {
      try {
        return await handleExchange(parameters);
      } on Exception catch (e) {
        return AuthFailure.fromException(e);
      }
    }
    return super.onFoundState(state: state, codeVerifier: codeVerifier);
  }

  @override
  Future<void> login({
    String? language,
    String? countryCode,
  }) async {
    final url = await authorize(
      language: language,
      countryCode: countryCode,
    );
    if (popupWindow is WindowClient && (popupWindow!.closed != true)) {
      (popupWindow as WindowClient).focus();
    } else {
      popupWindow = window.open(
        url,
        'login',
        'location=yes,status=yes,scrollbars=no,resizable=no,'
            'toolbar=no,width=550,height=450,popup=yes,noreferer=yes',
      );
    }

    if (popupWindow == null) {
      // TODO: Popup refused to open.
      throw Exception('Could not open popup');
    }

    final event = await window.onMessage.firstWhere((event) {
      final origin = Uri.tryParse(event.origin);
      final gateway = config.gatewayUrl;
      return origin?.authority == gateway.authority;
    });

    final parametersJson = event.data;
    if (parametersJson is! String) {
      throw AuthException(
        'Excepted JSON message, got ${parametersJson.runtimeType}',
      );
    }
    final parameters = jsonDecode(parametersJson);
    if (parameters is! Map) {
      throw AuthException(
        'Expected parameters map, got ${parameters.runtimeType}',
      );
    }
    await exchange(parameters.cast());
  }
}
