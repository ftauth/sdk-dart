// Autogenerated from Pigeon (v1.0.12), do not edit directly.
// See also: https://pub.dev/packages/pigeon
#import <Foundation/Foundation.h>
@protocol FlutterBinaryMessenger;
@protocol FlutterMessageCodec;
@class FlutterError;
@class FlutterStandardTypedData;

NS_ASSUME_NONNULL_BEGIN


/// The codec used by FTAuthNativeStorage.
NSObject<FlutterMessageCodec> *FTAuthNativeStorageGetCodec(void);

@protocol FTAuthNativeStorage
- (void)clearWithError:(FlutterError *_Nullable *_Nonnull)error;
- (void)deleteKey:(NSString *)key error:(FlutterError *_Nullable *_Nonnull)error;
- (nullable NSString *)getStringKey:(NSString *)key error:(FlutterError *_Nullable *_Nonnull)error;
- (void)initWithError:(FlutterError *_Nullable *_Nonnull)error;
- (void)setStringKey:(NSString *)key value:(NSString *)value error:(FlutterError *_Nullable *_Nonnull)error;
@end

extern void FTAuthNativeStorageSetup(id<FlutterBinaryMessenger> binaryMessenger, NSObject<FTAuthNativeStorage> *_Nullable api);

NS_ASSUME_NONNULL_END
