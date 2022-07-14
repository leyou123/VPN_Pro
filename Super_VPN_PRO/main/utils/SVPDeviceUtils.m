//
//  SVPDeviceUtils.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/13.
//

#import "SVPDeviceUtils.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
@import AdSupport;
@import UIKit;
@import Darwin;
@import CoreTelephony;
@import LocalAuthentication;
@import MessageUI;
@import SystemConfiguration.CaptiveNetwork;
@import SystemConfiguration;


static NSString *const kCreateSessionKey = @"kCreateSessionKey";
NSString *const kKeychainServiceKey = @"kKeychainServiceKey";
@implementation SVPDeviceUtils

+ (void)load {
    NSLog(@"app session: %@",[SVPDeviceUtils getAppSession]);
}

+ (NSDictionary *)deviceInfo {
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"idfa"] = [SVPDeviceUtils getIDFA];
    info[@"idfv"] = [SVPDeviceUtils getIDFV];
    info[@"language"] = [SVPDeviceUtils getLanguage];
    info[@"locale"] = [SVPDeviceUtils getCurrentLocale];
    info[@"timezone"] = [SVPDeviceUtils getTimeZone];
    info[@"system_version"] = [SVPDeviceUtils getOsVersion];
    info[@"device_type"] = [SVPDeviceUtils getModel];
    info[@"bundle_id"] = [SVPDeviceUtils getBundleID];
    info[@"bundle_version"] = [SVPDeviceUtils getBundleVersion];
    info[@"timestamp"] = [SVPDeviceUtils getTimeStamp];
    info[@"carrier_name"] = [SVPDeviceUtils getCarrierName];
    info[@"mobile_country_code"] = [SVPDeviceUtils getMobileCountryCode];
    info[@"is_wifi"] = [NSNumber numberWithBool:[SVPDeviceUtils isWifi]];
    info[@"is_sandbox"] = [NSNumber numberWithBool:[SVPDeviceUtils isSandboxEnvironment]];
    info[@"touchid_enabled"] = [NSNumber numberWithBool:[SVPDeviceUtils isTouchIDEnabled]];
    info[@"is_email_setup"] = [NSNumber numberWithBool:[SVPDeviceUtils isEmailSetup]];
    info[@"is_vpn_connected"] = [NSNumber numberWithBool:[SVPDeviceUtils isVPNConnected]];
    info[@"ssid"] = [SVPDeviceUtils getSSID];
    info[@"session"] = [SVPDeviceUtils getAppSession];
    info[@"is_proxy_set"] = [NSNumber numberWithBool:[SVPDeviceUtils isProxySet]];
    return info;
}

+(NSString*)getIDFA{
    __block NSString *idfa;
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                idfa = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
                     NSLog(@"%@",idfa);
            }else {
                idfa = @"00000000-0000-0000-0000-000000000000";
            }
        }];
    }else {
        idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        if (idfa == nil || idfa.length == 0) {
            idfa = @"00000000-0000-0000-0000-000000000000";
          }
    }
    return idfa;
}

+(NSString*)getIDFV{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

+(NSString*)getLanguage{
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    return language;
}

+(NSString*)getCurrentLocale{
    NSString *locale = [[NSLocale currentLocale] localeIdentifier];
    return locale;
}

+(NSString*)getTimeZone{
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSString *tzName = [timeZone name];
    return tzName;
}

+ (NSString *)getOsVersion {
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    return osVersion;
}

+ (NSString *)getModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *model = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return model;
}

+ (NSString *)getBundleID {
    return [[NSBundle mainBundle] bundleIdentifier];
}

+ (NSString *)getBundleVersion {
    return [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)getTimeStamp {
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time=[date timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}

+(NSString *)getCarrierName{
    CTTelephonyNetworkInfo* info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier* _carrier = info.subscriberCellularProvider;
    if (_carrier.carrierName == nil) {
        return @"";
    }
    return _carrier.carrierName;
}

+ (NSString *)getMobileCountryCode {
    CTTelephonyNetworkInfo* info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier* _carrier = info.subscriberCellularProvider;
    if (_carrier.mobileCountryCode == nil) {
        return @"";
    }
    return _carrier.mobileCountryCode;
}

+ (BOOL)isSandboxEnvironment {
    if([[[[NSBundle mainBundle] appStoreReceiptURL] lastPathComponent] isEqualToString:@"sandboxReceipt"]){
        return YES;
    }
    NSString *mobile_provision_path=[[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:mobile_provision_path]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isTouchIDEnabled {
    LAContext *context = [[LAContext alloc] init];
    NSError *error;
    BOOL isEnabled = [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                                          error:&error];
    if (!isEnabled) {
        //        [FBSDKAppEvents logEvent:kNO_TOUCH_ID_EVENT];
    }
    return isEnabled;
}

//手机邮箱是不是已经配置
+ (BOOL)isEmailSetup {
    if ([MFMailComposeViewController canSendMail]) {
        return YES;
    }else {
        //        [FBSDKAppEvents logEvent:kNO_EMAIL];
        return NO;
    }
}

+ (BOOL)isVPNConnected {
    NSDictionary *dict = CFBridgingRelease(CFNetworkCopySystemProxySettings());
    NSArray *keys = [dict[@"__SCOPED__"]allKeys];
    for (NSString *key in keys) {
        if ([key rangeOfString:@"tap"].location != NSNotFound ||
            [key rangeOfString:@"tun"].location != NSNotFound ||
            [key rangeOfString:@"ppp"].location != NSNotFound){
            return YES;
        }
    }
    return NO;
}

+ (NSString *)getSSID {
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
    NSDictionary *SSIDInfo;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = CFBridgingRelease(
                                     CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty) {
            break;
        }
    }
    if (SSIDInfo[@"BSSID"]) {
        return SSIDInfo[@"BSSID"];
    }
    return nil;
}

+ (NSInteger)isWifi {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    return flags == 2;
}

+ (NSNumber *)getAppSession {
    NSDate *installDate = [[NSUserDefaults standardUserDefaults] objectForKey:kCreateSessionKey];
    if (!installDate) {
        installDate = [NSDate date];
        [[NSUserDefaults standardUserDefaults] setObject:installDate forKey:kCreateSessionKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    NSDate *now = [NSDate date];
    NSTimeInterval time = [now timeIntervalSinceDate:installDate];
    int days = (int)time/(3600*24);
    return [NSNumber numberWithInt:days];
}

+(BOOL)isProxySet {
    CFDictionaryRef dicRef = CFNetworkCopySystemProxySettings();
    const CFStringRef config_url = (const CFStringRef)CFDictionaryGetValue(dicRef,
                                                                           (const void*)kCFNetworkProxiesProxyAutoConfigURLString);
    if(config_url!=nil){
        return YES;
    }
    const CFStringRef proxyCFstr = (const CFStringRef)CFDictionaryGetValue(dicRef,
                                                                           (const void*)kCFNetworkProxiesHTTPProxy);
    NSString *proxy = (__bridge NSString *)proxyCFstr;
    if(proxy!=nil){
        return YES;
    }
    return  NO;
}

+ (NSString *)getKeychainSavedString {
    NSMutableDictionary *keychainQuery = [NSMutableDictionary dictionaryWithObjectsAndKeys: (__bridge id)(kSecClassGenericPassword),kSecClass, kKeychainServiceKey, kSecAttrService, kKeychainServiceKey, kSecAttrAccount, kSecAttrAccessibleAfterFirstUnlock,kSecAttrAccessible,nil];
    id indKey = nil;
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id<NSCopying>)(kSecReturnData)];
    [keychainQuery setObject:(__bridge id)(kSecMatchLimitOne) forKey:(__bridge id<NSCopying>)(kSecMatchLimit)];
    
    CFTypeRef TypeRef = NULL;
    if (SecItemCopyMatching((__bridge_retained CFDictionaryRef)keychainQuery, &TypeRef) == noErr) {
        
        indKey = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData*)TypeRef];
    }
    return [[NSString alloc] initWithData:indKey encoding:NSUTF8StringEncoding];
}

+ (void)saveStringToKeychain:(NSString *)string {
    
    NSMutableDictionary *POuitefv = [NSMutableDictionary dictionaryWithObjectsAndKeys: (__bridge id)(kSecClassGenericPassword),kSecClass, kKeychainServiceKey, kSecAttrService, kKeychainServiceKey, kSecAttrAccount, kSecAttrAccessibleAfterFirstUnlock,kSecAttrAccessible,nil];
    SecItemDelete((__bridge CFDictionaryRef)(POuitefv));
    
    [POuitefv setObject:[NSKeyedArchiver archivedDataWithRootObject:[string dataUsingEncoding: NSUTF8StringEncoding]] forKey:(__bridge id<NSCopying>)(kSecValueData)];
    
    SecItemAdd((__bridge CFDictionaryRef)(POuitefv), NULL);
}

+ (void)deletes:(NSString *)service {
    
    NSMutableDictionary *POuitefv = [NSMutableDictionary dictionaryWithObjectsAndKeys: (__bridge id)(kSecClassGenericPassword),kSecClass, kKeychainServiceKey, kSecAttrService, kKeychainServiceKey, kSecAttrAccount, kSecAttrAccessibleAfterFirstUnlock,kSecAttrAccessible,nil];
    SecItemDelete((__bridge CFDictionaryRef)(POuitefv));
}

+ (NSString *)getUserID {
    NSString *userID = [self getKeychainSavedString];
    if (userID.length == 0) {
        userID = [[NSUUID UUID] UUIDString];
        [self saveStringToKeychain:userID];
    }
//    [self deletes:kKeychainServiceKey];
    NSLog(@"---------- %@",userID);

    return userID;
}

+ (NSString *)registrationID {
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *registration = [userDefault objectForKey:@"registrationID"];
    
    return registration;
}

+ (NSString *)getNowTimeTimestamp {
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString*timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
    ;
    return timeString;
}

+ (NSString *)svp_getIsBlock{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *is_block = [userDefaults objectForKey:@"is_block"];
    return [NSString stringWithFormat:@"%@",is_block];
}

+ (NSString *)svp_getIsBlockStatus{
    return @"1";
}

+ (NSString *)getForce{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *forceString = [userDefaults objectForKey:@"Force"];
    return [NSString stringWithFormat:@"%@",forceString];
}

+ (NSString *)svp_getForceUrl{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *forceString = [userDefaults objectForKey:@"ForceUrl"];
    return [NSString stringWithFormat:@"%@",forceString];
}

+ (BOOL)svp_getNeedStill{
//    NSString *VPNConnected_str = [NSString stringWithFormat:@"%i",[DeviceUtils isVPNConnected]];
//    NSString *proxySet_str = [NSString stringWithFormat:@"%i",[DeviceUtils isProxySet]];
    if ([SVPDeviceUtils isVPNConnected] == YES || [SVPDeviceUtils isProxySet] == YES) {
        return YES;
    }
    return NO;
}

+ (NSString *)svp_getAuthorization{
    NSUserDefaults *ipDefaults = [NSUserDefaults standardUserDefaults];
    NSString *ipString =  [ipDefaults objectForKey:@"authorization"];
    return [NSString stringWithFormat:@"%@",ipString];
}

+ (NSString *)getDesKeyString {
    
    unsigned char str[] = {(0xe3 ^ 'H'),(0xe3 ^ 'G'),(0xe3 ^ '2'),(0xe3 ^ '0'),(0xe3 ^ '1'),(0xe3 ^ '9'),(0xe3 ^ '1'),(0xe3 ^ '1'),(0xe3 ^ '\0')};
    unsigned char *p = str;
    while( ((*p) ^=  0xe3) != '\0')  p++;
    char result[9];
    memcpy((void *)result, str, 9);
    NSString *svp_returnString = [NSString stringWithUTF8String:result];
    return svp_returnString;
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+ (NSMutableArray *)arrayWithJsonString:(NSString *)jsonString{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSMutableArray *arr = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return arr;
}

+ (NSString *)svp_HTTPPATH{
    
    unsigned char str[] = {(0x33 ^ '3'),(0x33 ^ '.'),(0x33 ^ '1'),(0x33 ^ '3'),(0x33 ^ '5'),(0x33 ^ '.'),(0x33 ^ '1'),(0x33 ^ '6'),(0x33 ^ '2'),(0x33 ^ '.'),(0x33 ^ '3'),(0x33 ^ '0'),(0x33 ^ '\0')};
    unsigned char *p = str;
    while( ((*p) ^=  0x33) != '\0')  p++;
    char result[13];
    memcpy((void *)result, str, 13);
    NSString *svp_path = [NSString stringWithUTF8String:result];

    NSString *const BASE_URL = [NSString stringWithFormat:@"http://%@",svp_path];
    return BASE_URL;
}

@end
