import 'dart:convert';
import 'dart:html';

import 'package:amplify_appsync/amplify_appsync.dart';
import 'package:amplify_common/amplify_common.dart';
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angulardart/amplifyconfiguration.dart';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';

import 'package:angulardart/app_component.template.dart' as app_component;
import 'package:angulardart/config.dart';
import 'package:ftauth/ftauth.dart';

import 'main.template.dart' as self;

bool get _isDevMode {
  var enabled = false;
  assert(enabled = true);
  return enabled;
}

Config createConfig(AppConfig appConfig) {
  final currentUri =
      Uri.parse(window.location.href.replaceAll('127.0.0.1', 'localhost'));
  String redirectUrl;
  if (appConfig.env == Environment.dev) {
    redirectUrl = currentUri.resolve('/#/auth').toString();
  } else {
    redirectUrl = currentUri.resolve('/auth').toString();
  }
  return Config(
    gatewayUrl: appConfig.host,
    clientId: 'b4f919f3-8599-4439-8dc6-18cd8ccf2859',
    redirectUri: redirectUrl,
  );
}

StorageRepo getStorageRepo() => StorageRepo.instance;

LocationStrategy createLocationStrategy(
  PlatformLocation platformLocation,
  @Optional() String? baseUrl,
) {
  if (_isDevMode) {
    return HashLocationStrategy(platformLocation, baseUrl);
  } else {
    return PathLocationStrategy(platformLocation, baseUrl);
  }
}

AppConfig getAppConfig() {
  if (_isDevMode) {
    return AppConfig.dev();
  } else {
    return AppConfig.prod();
  }
}

AmplifyConfig getAmplifyConfig() {
  final json = jsonDecode(amplifyconfig) as Map;
  return AmplifyConfig.fromJson(json.cast());
}

AppSyncConfig getAppSyncConfig(AmplifyConfig config, FTAuth ftauth) {
  return AppSyncConfig.fromAmplifyConfig(
    config,
    authorization: AppSyncOidcAuthorization(() async {
      await ftauth.init();
      final state = ftauth.currentState;
      if (state is! AuthSignedIn) {
        return null;
      }
      print('Access Token: ${state.client.credentials.accessToken}');
      return state.client.credentials.accessToken;
    }),
  );
}

GraphQLClient createGraphQLClient(AppSyncConfig config) =>
    GraphQLClient(config: config);

@GenerateInjector(
  [
    ClassProvider(http.Client, useClass: BrowserClient),
    FactoryProvider(AppConfig, getAppConfig),
    FactoryProvider(Config, createConfig),
    FactoryProvider(StorageRepo, getStorageRepo),
    FactoryProvider(AmplifyConfig, getAmplifyConfig),
    FactoryProvider(
      AppSyncConfig,
      getAppSyncConfig,
      deps: [AmplifyConfig, FTAuth],
    ),
    FactoryProvider(GraphQLClient, createGraphQLClient),
    ClassProvider(FTAuth),
    ClassProvider(MetadataRepo),
    ClassProvider(CryptoRepo, useClass: CryptoRepoImpl),
    routerProviders,
    FactoryProvider(LocationStrategy, createLocationStrategy),
  ],
)
final InjectorFactory injector = self.injector$Injector;

void main() {
  runApp(app_component.AppComponentNgFactory, createInjector: injector);
}
