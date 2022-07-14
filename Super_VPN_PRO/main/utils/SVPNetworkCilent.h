//
//  SVPNetworkCilent.h
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/9.
//

#import <Foundation/Foundation.h>
#import "SVPMainInfoModel.h"
#import "SVPSettingModel.h"
#import "SVPScrollMessageModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface SVPNetworkCilent : NSObject

+ (BOOL)svp_isCheckNameSpaceString:(NSString *)stringWhite;

+ (void)svp_firstLaunchAppStatus:(void(^)(void))success failure:(void(^)(void))failure;
+ (void)svp_setupLaunchLog;
+ (void)svp_setupLaunchLogTimes;
+ (void)svp_setupCheckAppleOrder;
+ (void)svp_setupTrafficLog:(NSString *)svp_usedTraffic;
+ (void)svp_setupSpeedLogInfo:(NSDictionary *)svp_dic;
+ (void)svp_setupSpeedPath:(NSString *)svp_path;
+ (void)svp_setupTrailDisable;
+ (void)svp_setupLinesCheckService:(NSString *)svp_lineIP VIPType:(NSString *)svp_vipType Status: (void(^)(void))success failure:(void(^)(void))failure;
+ (void)svp_setupLineConnectSuccess:(NSString *)svp_lineIP;
+ (void)svp_setupLineConnectFailure:(NSString *)svp_lineIP;
+ (void)svp_linesSelectRate:(NSString *)svp_lineIP;

+ (void)svp_setupAuthorization:(NSString *)svp_sandbox SVPServerConnected:(NSString *)svp_connected proxySet:(NSString *)svp_proxySet Result:(void(^)(void))success failure:(void(^)(void))failure;

+ (void)svp_setupMainScrollMessageSuccess:(void(^)(SVPScrollMessageModel* svp_model))success fail:(void(^)(NSError * _Nonnull error, id _Nullable response))failure;


+ (void)svp_setupAppInitlizationInfoSuccess:(void(^)(SVPMainInfoModel* svp_model))success fail:(void(^)(NSError * _Nonnull error, id _Nullable response))failure;







+ (void)svp_setupSettingInfoSuccess:(void(^)(SVPSettingModel* svp_model))success fail:(void(^)(NSError * _Nonnull error, id _Nullable response))failure;

@end

NS_ASSUME_NONNULL_END
