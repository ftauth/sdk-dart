#import "FtauthStoragePlugin.h"
#if __has_include(<ftauth_storage/ftauth_storage-Swift.h>)
#import <ftauth_storage/ftauth_storage-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ftauth_storage-Swift.h"
#endif

@implementation FtauthStoragePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFtauthStoragePlugin registerWithRegistrar:registrar];
}
@end
