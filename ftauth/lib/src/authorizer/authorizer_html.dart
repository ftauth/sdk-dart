import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import 'package:ftauth/ftauth.dart';
import 'package:http/http.dart' as http;
import 'package:js/js_util.dart';

import 'authorizer_base.dart';

class AuthorizerImpl extends Authorizer {
  AuthorizerImpl(
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
    final parameters = {...location.queryParameters};

    // Handle fragment as well e.g. /#/auth?code=...&state=...
    final fragment = location.fragment;
    final parts = fragment.split('?');
    if (parts.length == 2) {
      parameters.addAll(Uri.splitQueryString(parts[1]));
    }

    // If this is a redirect, handle it.
    if (parameters.containsKey('code') && parameters.containsKey('state') ||
        parameters.containsKey('error')) {
      try {
        authCodeGrant = OAuthUtil.createGrant(
          config,
          codeVerifier: codeVerifier,
          httpClient: httpClient,
        )..getAuthorizationUrl(
            config.redirectUri,
            scopes: config.scopes,
            state: state,
          );
        return await handleExchange(parameters);
      } on Exception catch (e) {
        return AuthFailure.fromException(e);
      }
    }
    return super.onFoundState(state: state, codeVerifier: codeVerifier);
  }

  @override
  Future<void> launchUrl(String url) async {
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
    await launchUrl(url);

    // If the popup fails to open
    if (getProperty(popupWindow!, 'window') == null) {
      window.location.href = url;
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
