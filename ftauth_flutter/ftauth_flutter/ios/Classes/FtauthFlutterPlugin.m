#import "FtauthFlutterPlugin.h"
#if __has_include(<ftauth_flutter/ftauth_flutter-Swift.h>)
#import <ftauth_flutter/ftauth_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ftauth_flutter-Swift.h"
#endif

@implementation FtauthFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFtauthFlutterPlugin registerWithRegistrar:registrar];
}
@end
