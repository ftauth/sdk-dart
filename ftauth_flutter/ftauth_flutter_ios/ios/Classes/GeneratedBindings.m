// Autogenerated from Pigeon (v1.0.12), do not edit directly.
// See also: https://pub.dev/packages/pigeon
#import "GeneratedBindings.h"
#import <Flutter/Flutter.h>

#if !__has_feature(objc_arc)
#error File requires ARC to be enabled.
#endif

static NSDictionary<NSString *, id> *wrapResult(id result, FlutterError *error) {
  NSDictionary *errorDict = (NSDictionary *)[NSNull null];
  if (error) {
    errorDict = @{
        @"code": (error.code ? error.code : [NSNull null]),
        @"message": (error.message ? error.message : [NSNull null]),
        @"details": (error.details ? error.details : [NSNull null]),
        };
  }
  return @{
      @"result": (result ? result : [NSNull null]),
      @"error": errorDict,
      };
}

@interface FTAuthClientConfiguration ()
+ (FTAuthClientConfiguration *)fromMap:(NSDictionary *)dict;
- (NSDictionary *)toMap;
@end

@implementation FTAuthClientConfiguration
+ (FTAuthClientConfiguration *)fromMap:(NSDictionary *)dict {
  FTAuthClientConfiguration *result = [[FTAuthClientConfiguration alloc] init];
  result.authorizationEndpoint = dict[@"authorizationEndpoint"];
  if ((NSNull *)result.authorizationEndpoint == [NSNull null]) {
    result.authorizationEndpoint = nil;
  }
  result.tokenEndpoint = dict[@"tokenEndpoint"];
  if ((NSNull *)result.tokenEndpoint == [NSNull null]) {
    result.tokenEndpoint = nil;
  }
  result.clientId = dict[@"clientId"];
  if ((NSNull *)result.clientId == [NSNull null]) {
    result.clientId = nil;
  }
  result.clientSecret = dict[@"clientSecret"];
  if ((NSNull *)result.clientSecret == [NSNull null]) {
    result.clientSecret = nil;
  }
  result.redirectUri = dict[@"redirectUri"];
  if ((NSNull *)result.redirectUri == [NSNull null]) {
    result.redirectUri = nil;
  }
  result.scopes = dict[@"scopes"];
  if ((NSNull *)result.scopes == [NSNull null]) {
    result.scopes = nil;
  }
  result.state = dict[@"state"];
  if ((NSNull *)result.state == [NSNull null]) {
    result.state = nil;
  }
  result.codeVerifier = dict[@"codeVerifier"];
  if ((NSNull *)result.codeVerifier == [NSNull null]) {
    result.codeVerifier = nil;
  }
  return result;
}
- (NSDictionary *)toMap {
  return [NSDictionary dictionaryWithObjectsAndKeys:(self.authorizationEndpoint ? self.authorizationEndpoint : [NSNull null]), @"authorizationEndpoint", (self.tokenEndpoint ? self.tokenEndpoint : [NSNull null]), @"tokenEndpoint", (self.clientId ? self.clientId : [NSNull null]), @"clientId", (self.clientSecret ? self.clientSecret : [NSNull null]), @"clientSecret", (self.redirectUri ? self.redirectUri : [NSNull null]), @"redirectUri", (self.scopes ? self.scopes : [NSNull null]), @"scopes", (self.state ? self.state : [NSNull null]), @"state", (self.codeVerifier ? self.codeVerifier : [NSNull null]), @"codeVerifier", nil];
}
@end

@interface FTAuthNativeLoginCodecReader : FlutterStandardReader
@end
@implementation FTAuthNativeLoginCodecReader
- (nullable id)readValueOfType:(UInt8)type 
{
  switch (type) {
    case 128:     
      return [FTAuthClientConfiguration fromMap:[self readValue]];
    
    default:    
      return [super readValueOfType:type];
    
  }
}
@end

@interface FTAuthNativeLoginCodecWriter : FlutterStandardWriter
@end
@implementation FTAuthNativeLoginCodecWriter
- (void)writeValue:(id)value 
{
  if ([value isKindOfClass:[FTAuthClientConfiguration class]]) {
    [self writeByte:128];
    [self writeValue:[value toMap]];
  } else 
{
    [super writeValue:value];
  }
}
@end

@interface FTAuthNativeLoginCodecReaderWriter : FlutterStandardReaderWriter
@end
@implementation FTAuthNativeLoginCodecReaderWriter
- (FlutterStandardWriter *)writerWithData:(NSMutableData *)data {
  return [[FTAuthNativeLoginCodecWriter alloc] initWithData:data];
}
- (FlutterStandardReader *)readerWithData:(NSData *)data {
  return [[FTAuthNativeLoginCodecReader alloc] initWithData:data];
}
@end

NSObject<FlutterMessageCodec> *FTAuthNativeLoginGetCodec() {
  static dispatch_once_t s_pred = 0;
  static FlutterStandardMessageCodec *s_sharedObject = nil;
  dispatch_once(&s_pred, ^{
    FTAuthNativeLoginCodecReaderWriter *readerWriter = [[FTAuthNativeLoginCodecReaderWriter alloc] init];
    s_sharedObject = [FlutterStandardMessageCodec codecWithReaderWriter:readerWriter];
  });
  return s_sharedObject;
}


void FTAuthNativeLoginSetup(id<FlutterBinaryMessenger> binaryMessenger, NSObject<FTAuthNativeLogin> *api) {
  {
    FlutterBasicMessageChannel *channel =
      [FlutterBasicMessageChannel
        messageChannelWithName:@"dev.flutter.pigeon.NativeLogin.login"
        binaryMessenger:binaryMessenger
        codec:FTAuthNativeLoginGetCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(loginConfig:completion:)], @"FTAuthNativeLogin api (%@) doesn't respond to @selector(loginConfig:completion:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        FTAuthClientConfiguration *arg_config = args[0];
        [api loginConfig:arg_config completion:^(NSDictionary<NSString *, NSString *> *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult(output, error));
        }];
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
}
