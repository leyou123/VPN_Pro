//
//  SVPDeviceUtils.h
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SVPDeviceUtils : NSObject
+ (NSDictionary *)deviceInfo;
+ (NSString *)getIDFA;
+ (NSString *)getLanguage;
+ (NSString *)getCurrentLocale;
+ (NSString *)getTimeZone;
+ (NSString *)getOsVersion;
+ (NSString *)getModel;
+ (NSString *)getBundleID ;
+ (NSString *)getBundleVersion;
+ (NSString *)getTimeStamp;
+ (NSString *)getCarrierName;
+ (NSString *)getMobileCountryCode;
+ (NSInteger)isWifi;
+ (BOOL)isSandboxEnvironment;
+ (BOOL)isTouchIDEnabled;
+ (BOOL)isEmailSetup;
+ (NSString *)getSSID;
+ (BOOL)isVPNConnected;
+ (BOOL)isProxySet;
+ (NSString *)getUserID;
+ (NSString *)registrationID;
+ (NSString *)getNowTimeTimestamp;
+ (NSString *)svp_getIsBlock;
+ (NSString *)svp_getIsBlockStatus;
+ (NSString *)getKeychainSavedString;
+ (void)saveStringToKeychain: (NSString *)string;
+ (void)deletes:(NSString *)service;
+ (NSString *)getForce;
+ (NSString *)svp_getForceUrl;
+ (BOOL)svp_getNeedStill;
+ (NSString *)svp_getAuthorization;
+ (NSString *)svp_HTTPPATH;
+ (NSString *)getDesKeyString;
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
+ (NSMutableArray *)arrayWithJsonString:(NSString *)jsonString;
@end

NS_ASSUME_NONNULL_END
