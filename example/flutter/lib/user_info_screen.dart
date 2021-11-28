import 'package:flutter/material.dart';
import 'package:ftauth_example/keys.dart';
import 'package:ftauth_flutter/ftauth_flutter.dart';

class UserInfoScreen extends StatefulWidget {
  static const userInfoUrl =
      'https://carelink-stage.minimed.eu/patient/users/me';

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
      final resp = await _getUserInfo(ssoClient);
      setState(() {
        _isLoading = false;
        _response = resp;
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

  Future<String> _getUserInfo(FTAuthClient ssoClient) async {
    final userInfoUri = Uri.parse(UserInfoScreen.userInfoUrl);
    final resp = await ssoClient.get(userInfoUri);
    if (resp.statusCode != 200) {
      throw ApiException.get(userInfoUri, resp.statusCode, resp.body);
    }
    return resp.body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key(keyUserInfoScreen),
      appBar: AppBar(title: const Text('User Info')),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('GET ${UserInfoScreen.userInfoUrl}'),
              const Divider(),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                Text(_response != null
                    ? _response!
                    : _error ?? 'An unknown error occurred'),
            ],
          ),
        ),
      ),
    );
  }
}
