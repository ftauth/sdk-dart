import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ftauth/src/authorizer/keys.dart';
import 'package:ftauth/src/repo/ssl/keys.dart';
import 'package:ftauth_example/embedded_login_screen.dart';
import 'package:ftauth_flutter/ftauth_flutter.dart';

import 'auth_state_indicator.dart';
import 'data/locales.dart';
import 'dropdowns.dart';
import 'keys.dart';
import 'user_info_screen.dart';

const appGroup = 'group.io.ftauth.ftauth_example';
final storageRepo = FTAuthSecureStorage(
  appGroup: appGroup,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = Config(
    gatewayUrl: 'http://localhost:8080',
    clientId: '10ef6d61-1a83-44e0-94bb-1675ac50d397',
    redirectUri: 'myapp://auth',
    grantTypes: [
      'authorization_code',
      'refresh_token',
    ],
    refreshTokenFormat: TokenFormat.jwt,
  );

  runApp(
    FTAuth(
      config,
      storageRepo: storageRepo,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const _defaultLanguage = 'en';
  static const _defaultCountryCode = 'gb';

  late final List<Language> _languages;
  late final List<Country> _countries;

  Language? _selectedLanguage;
  Country? _selectedCountry;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final countries = await loadCountries();
    final languages = await loadLanguages();

    setState(() {
      _languages = languages..sort((a, b) => a.name.compareTo(b.name));
      _countries = countries..sort((a, b) => a.name.compareTo(b.name));
      _selectedCountry = countries.firstWhere(
        (country) => country.isoCode.toLowerCase() == _defaultCountryCode,
      );
      _selectedLanguage = languages.firstWhere(
        (language) => language.code.toLowerCase() == _defaultLanguage,
      );
      _isInitialized = true;
    });
  }

  Future<void> _dumpKeychain() async {
    final entries = await Future.wait(
      [
        keyAccessToken,
        keyAccessTokenExp,
        keyRefreshToken,
        keyIdToken,
        keyState,
        keyCodeVerifier,
        keyUserInfo,
        keyConfig,
        keyPinnedCertificates,
        keyPinnedCertificateChains,
      ].map((key) async {
        final value = await storageRepo.getString(key);
        if (value == null) {
          return MapEntry(key, value);
        }
        try {
          final jsonObj = jsonDecode(value);
          return MapEntry(key, jsonObj);
        } on FormatException {
          return MapEntry(key, value);
        }
      }),
    );
    final json = JsonEncoder.withIndent('\t').convert(Map.fromEntries(entries));
    debugPrint(json);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: const Key(keyHomeScreen),
        appBar: AppBar(
          title: const Text('FTAuth Example'),
        ),
        body: Builder(
          builder: (context) {
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Authorization State'),
                    const SizedBox(height: 5),
                    const AuthStateIndicator(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: const Divider(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          const Text('Language:'),
                          const SizedBox(width: 10),
                          if (_isInitialized)
                            LanguageDropdown(
                              value: _selectedLanguage,
                              languages: _languages,
                              onSelect: (Language? language) {
                                setState(() => _selectedLanguage = language);
                              },
                            )
                          else
                            const CircularProgressIndicator(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          const Text('Country:'),
                          const SizedBox(width: 10),
                          if (_isInitialized)
                            CountryDropdown(
                              value: _selectedCountry,
                              countries: _countries,
                              onSelect: (Country? country) {
                                setState(() => _selectedCountry = country);
                              },
                            )
                          else
                            const CircularProgressIndicator(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: const Divider(),
                    ),
                    ElevatedButton(
                      key: Key(keyLoginButton),
                      child: const Text('Login'),
                      onPressed: () => FTAuth.of(context).login(
                        language: _selectedLanguage?.code,
                        countryCode: _selectedCountry?.isoCode,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      key: Key(keyLoginEmbeddedButton),
                      child: const Text('Login (Embedded)'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EmbeddedLoginScreen(
                            language: _selectedLanguage?.code,
                            countryCode: _selectedCountry?.isoCode,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      key: Key(keyUserInfoButton),
                      child: const Text('Get User Info'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => UserInfoScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      key: Key(keyDumpKeychainButton),
                      child: const Text('Dump Keychain'),
                      onPressed: _dumpKeychain,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      key: Key(keyLogoutButton),
                      child: const Text('Logout'),
                      onPressed: () => FTAuth.of(context).logout(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
