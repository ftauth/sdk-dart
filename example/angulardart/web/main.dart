import 'dart:convert';

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

late AppConfig _appConfig;
AppConfig getAppConfig() => _appConfig;

StorageRepo getStorageRepo() => StorageRepo.instance;

LocationStrategy createLocationStrategy(
  PlatformLocation platformLocation,
  @Optional() String? baseUrl,
) {
  return HashLocationStrategy(platformLocation, baseUrl);
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
      return state.client.credentials.accessToken;
    }),
  );
}

FTAuth getFTAuthClient(AppConfig config, StorageRepo storageRepo) {
  return FTAuth(config.config, storageRepo: storageRepo);
}

GraphQLClient createGraphQLClient(AppSyncConfig config) =>
    GraphQLClient(config: config);

@GenerateInjector(
  [
    ClassProvider(http.Client, useClass: BrowserClient),
    FactoryProvider(AppConfig, getAppConfig),
    FactoryProvider(StorageRepo, getStorageRepo),
    FactoryProvider(AmplifyConfig, getAmplifyConfig),
    FactoryProvider(
      AppSyncConfig,
      getAppSyncConfig,
      deps: [AmplifyConfig, FTAuth],
    ),
    FactoryProvider(GraphQLClient, createGraphQLClient),
    FactoryProvider(FTAuth, getFTAuthClient),
    ClassProvider(MetadataRepo),
    ClassProvider(CryptoRepo, useClass: CryptoRepoImpl),
    routerProviders,
    FactoryProvider(LocationStrategy, createLocationStrategy),
  ],
)
final InjectorFactory injector = self.injector$Injector;

Future<void> main() async {
  _appConfig = //
      // _isDevMode
      //     ? AppConfig.dev()
      //     : //
      await AppConfig.prod();
  runApp(
    app_component.AppComponentNgFactory,
    createInjector: injector,
  );
}
