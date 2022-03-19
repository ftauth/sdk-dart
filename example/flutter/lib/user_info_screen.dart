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
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_response == null) {
      _refreshState();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshState();
    }
  }

  String? get _currentUser => FTAuth.of(context).currentUser?.toString();

  Future<void> _refreshState() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FTAuth.of(context).refreshAuthState();
      setState(() {
        _isLoading = false;
        _response = _currentUser;
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
          child: _isLoading
              ? const CircularProgressIndicator()
              : Text((_error ?? _response).toString()),
        ),
      ),
    );
  }
}
