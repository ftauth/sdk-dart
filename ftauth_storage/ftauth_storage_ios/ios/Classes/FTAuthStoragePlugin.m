#import "FTAuthStoragePlugin.h"
#if __has_include(<ftauth_storage_ios/ftauth_storage_ios-Swift.h>)
#import <ftauth_storage_ios/ftauth_storage_ios-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ftauth_storage_ios-Swift.h"
#endif

@implementation FTAuthStoragePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFTAuthStoragePlugin registerWithRegistrar:registrar];
}
@end
