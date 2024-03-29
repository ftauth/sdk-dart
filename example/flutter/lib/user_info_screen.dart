import 'package:flutter/material.dart';
import 'package:ftauth_example/keys.dart';
import 'package:ftauth_flutter/ftauth_flutter.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({Key? key}) : super(key: key);

  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen>
    with WidgetsBindingObserver {
  bool _isLoading = true;
  String? _response;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_response == null) {
      _refreshState(FTAuth.of(context));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshState(FTAuth.of(context));
    }
  }

  Future<void> _refreshState(FTAuthClient ssoClient) async {
    setState(() {
      _isLoading = true;
    });
    try {
      setState(() {
        _isLoading = false;
        // _response = resp;
        _error = null;
      });
    } on Exception catch (e) {
      setState(() {
        _isLoading = false;
        _response = null;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key(keyUserInfoScreen),
      appBar: AppBar(title: const Text('User Info')),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Text(FTAuth.of(context).currentUser.toString()),
        ),
      ),
    );
  }
}
