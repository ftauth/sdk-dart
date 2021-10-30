import 'package:flutter/material.dart';

import 'embedded_login_view.dart';

/// An error popup for [EmbeddedLoginView].
class LoginErrorPopupView extends StatelessWidget {
  final String error;
  final String errorTitle;
  final String okButtonLabel;

  const LoginErrorPopupView(
    this.error, {
    Key? key,
    this.errorTitle = 'Login Error',
    this.okButtonLabel = 'OK',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(errorTitle),
      content: Text(error),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(okButtonLabel),
        ),
      ],
    );
  }
}
