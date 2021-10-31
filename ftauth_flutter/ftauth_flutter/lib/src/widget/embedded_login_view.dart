import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ftauth_flutter/ftauth_flutter.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Converts errors into strings for display in a popup.
typedef ErrorHandler = String Function(Object);

/// A login page view that can be used within an app, unlike the standard flow
/// which requires showing a Safari WebView popup (iOS) or switching to a Chrome
/// process (Android).
///
/// Note: Press Cmd+Shift+K in iOS Simulator if you don't see the keyboard.
class EmbeddedLoginView extends StatefulWidget {
  final String? language;
  final String? countryCode;

  /// Error handler which converts [Exception]s in the login flow to readable strings
  /// which can be shown to users in a popup.
  ///
  /// Most exceptions will be due to HTTP connection issues but some other
  /// abberant issues may occur as well if there are issues on the server.
  final ErrorHandler errorHandler;

  static String _defaultErrorHandler(error) => error.toString();

  const EmbeddedLoginView({
    Key? key,
    this.language,
    this.countryCode,
    this.errorHandler = _defaultErrorHandler,
  }) : super(key: key);

  @override
  EmbeddedLoginViewState createState() => EmbeddedLoginViewState();
}

class EmbeddedLoginViewState extends State<EmbeddedLoginView> {
  /// The web view controller. Can be used to inject JS commands, like in
  /// integration testing.
  late final WebViewController controller;

  /// Completes when the initial login page load finishes.
  final Completer<void> loadedLoginPage = Completer();

  /// The initial login URL loaded into the view. Used to compare against
  /// later URLs to know when we've moved pass the login page.
  String? _initialUrl;

  /// Whether or not to show the loading indicator.
  bool _isLoading = true;

  /// Whether there is an error popup showing. Used to prevent multiple popups
  /// from peresenting at once.
  bool _isErrorPopupShowing = false;

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  Future<void> _showErrorPopup(Object error) async {
    if (_isErrorPopupShowing) {
      return;
    }
    _isErrorPopupShowing = true;
    final errorString = widget.errorHandler(error);
    await showDialog(
      context: context,
      builder: (_) => LoginErrorPopupView(errorString),
    );

    // Once the dialog is closed, logout (i.e. cancel the auth request)
    // and pop to the previous screen.

    await FTAuth.of(context).logout();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _exchangeWithParameters(Map<String, String> parameters) async {
    try {
      await FTAuth.of(context).exchange(parameters);

      _onLoggedIn();
    } on Exception catch (e) {
      return _showErrorPopup(e);
    }
  }

  /// Callback for successful login. Return to the previous screen.
  void _onLoggedIn() {
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ssoClient = FTAuth.of(context);
    return WillPopScope(
      onWillPop: () async {
        // Will fire only if the user clicks the back button. Ensures that the
        // login flow is cancelled properly.
        await ssoClient.logout();
        return true;
      },
      child: Stack(
        children: [
          WebView(
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController controller) async {
              this.controller = controller;
              try {
                final isLoggedIn = await ssoClient.isLoggedIn;
                if (isLoggedIn) {
                  _onLoggedIn();
                  return;
                }
                final authorizeUrl = await ssoClient.authorize(
                  language: widget.language,
                  countryCode: widget.countryCode,
                );
                controller.loadUrl(authorizeUrl);
              } on Exception catch (e) {
                FTAuth.error('Error calling authorize: $e');
                setState(() => _isLoading = false);
                _showErrorPopup(e);
              }
            },
            navigationDelegate: (NavigationRequest navigation) async {
              final url = Uri.parse(navigation.url);
              if (url.scheme == ssoClient.config.redirectUri.scheme) {
                _exchangeWithParameters(url.queryParameters);
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
            onPageStarted: (String url) {
              FTAuth.debug('WebView - Loading url: $url');
              // Will be true if the login page is reloaded, for example, if
              // the user enters an incorrect password.
              final isReload = _initialUrl == null
                  ? false
                  : Uri.parse(_initialUrl!).path == Uri.parse(url).path;
              if (!_isLoading && !isReload) {
                setState(() => _isLoading = true);
              }
            },
            onPageFinished: (String url) {
              FTAuth.debug('WebView - Loaded url: $url');
              if (!loadedLoginPage.isCompleted) {
                _initialUrl = url;
                setState(() {
                  _isLoading = false;
                  loadedLoginPage.complete();
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              // These are typically not critical errors. For example, preventing
              // a webpage from loading, which we do a couple times, will result
              // in an error.
              //
              // They should be monitored, though, in case some other issues occur.
              FTAuth.info('Error in WebView: ${error.description}');
            },
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
