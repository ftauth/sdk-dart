import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:ftauth_example/keys.dart';
import 'package:ftauth_flutter/ftauth_flutter.dart';

class EmbeddedLoginScreen extends StatefulWidget {
  final String language;
  final String countryCode;

  const EmbeddedLoginScreen({
    Key key,
    this.language,
    this.countryCode,
  }) : super(key: key);

  @override
  _EmbeddedLoginScreenState createState() => _EmbeddedLoginScreenState();
}

class _EmbeddedLoginScreenState extends State<EmbeddedLoginScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ssoClient = FTAuthClient.of(context);
    ssoClient.authStates
        .firstWhere((state) => state is AuthSignedIn || state is AuthFailure)
        .then((_) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key(keyEmbeddedLoginScreen),
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: EmbeddedLoginView(
          language: widget.language,
          countryCode: widget.countryCode,
        ),
      ),
    );
  }
}
