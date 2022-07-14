//
//  SVPNetworkCilent.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/9.
//

#import "SVPNetworkCilent.h"
#import "SVPInterfaceManager.h"
#import "SVPDeviceUtils.h"
#import "SVPLocalDataTool.h"
#import "SVPDes.h"
#import "STNetMeasure.h"

@implementation SVPNetworkCilent

+ (void)svp_firstLaunchAppStatus:(void(^)(void))success failure:(void(^)(void))failure{
    NSString *path = @"/v1/activate";
    NSString *userID = [[NSUUID UUID] UUIDString];
    NSString *fullPath = [NSString stringWithFormat:@"%@", path];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:userID forKey:@"activate_id"];
    [SVPInterfaceManager svp_get:fullPath withParams:dic success:^(id  _Nullable response) {
        [SVPDeviceUtils saveStringToKeychain:userID];
        success();
        } failure:^(NSError * _Nonnull error, id  _Nullable response) {
            failure();
            NSLog(@"激活接口error:%@__%@",error,response);
        }];
}

+ (void)svp_setupLaunchLog {
    NSString *svp_launchLogPath = @"/v1/log";
    [SVPInterfaceManager svp_get:svp_launchLogPath withParams:[self svp_launchLogDictionary] success:^(id  _Nullable response) {
        NSLog(@"+++++++++++%@",response);
    } failure:^(NSError * _Nonnull error,id  _Nullable response) {
        NSLog(@"error:%@",error);
    }];
}

+ (void)svp_setupLaunchLogTimes{
    NSString *path = @"/v1/log/open";
    [SVPInterfaceManager svp_get:path withParams:[self svp_launchLogDictionary] success:^(id  _Nullable response) {
        NSLog(@"Open Times+++++++++++%@",response);
        } failure:^(NSError * _Nonnull error, id  _Nullable response) {
            NSLog(@"Open Times error+++++++++++%@",error);
        }];
}


+ (NSDictionary *)svp_launchLogDictionary {
    NSString *svp_wifi_str = [NSString stringWithFormat:@"%ld",(long)[SVPDeviceUtils isWifi]];
    NSString *svp_sandbox_str = [NSString stringWithFormat:@"%i",[SVPDeviceUtils isSandboxEnvironment]];
    NSString *svp_VPNConnected_str = [NSString stringWithFormat:@"%i",[SVPDeviceUtils isVPNConnected]];
    NSString *svp_proxySet_str = [NSString stringWithFormat:@"%i",[SVPDeviceUtils isProxySet]];
    NSString *svp_stringTag;
    if ([SVPDeviceUtils svp_getNeedStill]) {
        svp_stringTag = [SVPDeviceUtils svp_getAuthorization];
    }else{
        svp_stringTag = @"null";
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (![self svp_isCheckNameSpaceString:[SVPDeviceUtils getBundleVersion]]) {
        [params setObject:[SVPDeviceUtils getBundleVersion] forKey:@"app_version"];
    }
    if (![self svp_isCheckNameSpaceString:[SVPDeviceUtils getIDFA]]) {
        [params setObject:[SVPDeviceUtils getIDFA] forKey:@"idfa"];
        NSLog(@"++++++++%@",[SVPDeviceUtils getIDFA]);
    }
    if (![self svp_isCheckNameSpaceString:[SVPDeviceUtils registrationID]]) {
        [params setObject:[SVPDeviceUtils registrationID] forKey:@"push_id"];
    }
    if (![self svp_isCheckNameSpaceString:[SVPDeviceUtils getCurrentLocale]]) {
        [params setObject:[SVPDeviceUtils getCurrentLocale] forKey:@"locale"];
    }
    if (![self svp_isCheckNameSpaceString:[SVPDeviceUtils getTimeStamp]]) {
        [params setObject:[SVPDeviceUtils getTimeStamp] forKey:@"timestamp"];
    }
    if (![self svp_isCheckNameSpaceString:[SVPDeviceUtils getTimeZone]]) {
        [params setObject:[SVPDeviceUtils getTimeZone] forKey:@"timezone"];
    }
    if (![self svp_isCheckNameSpaceString:[SVPDeviceUtils getOsVersion]]) {
        [params setObject:[SVPDeviceUtils getOsVersion] forKey:@"system_version"];
    }
    if (![self svp_isCheckNameSpaceString:[SVPDeviceUtils getModel]]) {
        [params setObject:[SVPDeviceUtils getModel] forKey:@"device_type"];
    }
    if (![self svp_isCheckNameSpaceString:[SVPDeviceUtils getBundleID]]) {
        [params setObject:[SVPDeviceUtils getBundleID] forKey:@"bundle_id"];
    }
    if (![self svp_isCheckNameSpaceString:[SVPDeviceUtils getBundleVersion]]) {
        [params setObject:[SVPDeviceUtils getBundleVersion] forKey:@"bundle_version"];
    }
    if (![self svp_isCheckNameSpaceString:[SVPDeviceUtils getCarrierName]]) {
        [params setObject:[SVPDeviceUtils getCarrierName] forKey:@"carrier_name"];
    }
    if (![self svp_isCheckNameSpaceString:[SVPDeviceUtils getMobileCountryCode]]) {
        [params setObject:[SVPDeviceUtils getMobileCountryCode] forKey:@"mobile_country_code"];
    }
    
    if (![self svp_isCheckNameSpaceString:svp_wifi_str]) {
        [params setObject:svp_wifi_str forKey:@"is_wifi"];
    }
    if (![self svp_isCheckNameSpaceString:svp_sandbox_str]) {
        [params setObject:svp_sandbox_str forKey:@"is_sandbox"];
    }
    if (![self svp_isCheckNameSpaceString:svp_VPNConnected_str]) {
        [params setObject:svp_VPNConnected_str forKey:@"is_vpn_connected"];
    }
    if (![self svp_isCheckNameSpaceString:svp_proxySet_str]) {
        [params setObject:svp_proxySet_str forKey:@"is_proxy_set"];
    }
    if (![self svp_isCheckNameSpaceString:svp_stringTag]) {
        [params setObject:svp_stringTag forKey:@"tag"];
    }
    return params;
}

+ (void)svp_setupAuthorization:(NSString *)svp_sandbox SVPServerConnected:(NSString *)svp_connected proxySet:(NSString *)svp_proxySet Result:(void(^)(void))success failure:(void(^)(void))failure {
    NSString *svp_path = @"/v1/authorization";
    NSString *svp_stringTag;
    if ([SVPDeviceUtils svp_getNeedStill]) {
        svp_stringTag = [SVPDeviceUtils svp_getAuthorization];
    }else{
        svp_stringTag = @"";
    }
    NSMutableDictionary *svp_dic = [NSMutableDictionary dictionary];
    [svp_dic setObject:[SVPDeviceUtils getBundleVersion] forKey:@"app_version"];
    [svp_dic setObject:svp_sandbox forKey:@"is_sandbox"];
    [svp_dic setObject:svp_connected forKey:@"is_vpn_connected"];
    [svp_dic setObject:svp_proxySet forKey:@"is_proxy_set"];
    [svp_dic setObject:svp_stringTag forKey:@"tag"];
    
    [SVPInterfaceManager svp_get:svp_path withParams:svp_dic success:^(id  _Nullable response) {
        [SVPLocalDataTool setObject:[response objectForKey:@"data"] forKey:@"authorization"];
        success();
        } failure:^(NSError * _Nonnull error, id  _Nullable response) {
        failure();
        }];
}

+ (void)svp_setupAppInitlizationInfoSuccess:(void(^)(SVPMainInfoModel* svp_model))success fail:(void(^)(NSError * _Nonnull error, id _Nullable response))failure {
    NSString *svp_path = @"/v1/app";
    NSString *svp_tagString;
    if([SVPDeviceUtils svp_getNeedStill]) {
        svp_tagString = [SVPDeviceUtils svp_getAuthorization];
    }else {
        svp_tagString = @"";
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[SVPDeviceUtils getBundleVersion] forKey:@"app_version"];
    [dic setObject:svp_tagString forKey:@"tag"];
    
    [SVPInterfaceManager svp_get:svp_path withParams:dic success:^(id  _Nullable response) {
        NSLog(@"AppInitlization :%@",response);
        NSDictionary *resultDic = [response objectForKey:@"data"];
        SVPMainInfoModel *svp_Model = [[SVPMainInfoModel alloc]init];
        svp_Model.svp_AdDataDic = [resultDic objectForKey:@"ad"];
        svp_Model.svp_Award_adDic = [resultDic objectForKey:@"award_ad"];
        svp_Model.svp_Speed_TestDic = [resultDic objectForKey:@"speed_test"];
        svp_Model.svp_award_title = svp_Model.svp_Award_adDic[@"award_1_data"][@"title"];
        svp_Model.svp_service_mail = [resultDic objectForKey:@"service_mail"];
        svp_Model.svp_is_blockString = [resultDic objectForKey:@"is_block"];
        svp_Model.svp_server_delay_type = [resultDic objectForKey:@"server_delay_type"];
        svp_Model.svp_server_select_type = [resultDic objectForKey:@"server_select_type"];
        svp_Model.svp_service_url = [resultDic objectForKey:@"service_url"];
        svp_Model.svp_privacy_url = [resultDic objectForKey:@"privacy_url"];
        svp_Model.svp_purchase_verify_time = [resultDic objectForKey:@"purchase_verify_time"];
        svp_Model.svp_traffic_update_time = [resultDic objectForKey:@"traffic_update_time"];
        svp_Model.svp_notice_switch = [resultDic objectForKey:@"notice_switch"];
        svp_Model.svp_update_switch = [resultDic objectForKey:@"update_switch"];
        svp_Model.svp_update_url_switch = [resultDic objectForKey:@"update_url_switch"];
        svp_Model.svp_update_url = [resultDic objectForKey:@"update_url"];
        success(svp_Model);
        } failure:^(NSError * _Nonnull error, id  _Nullable response) {
            failure(error,response);
        }];
}


+ (void)svp_setupMainScrollMessageSuccess:(void(^)(SVPScrollMessageModel* svp_model))success fail:(void(^)(NSError * _Nonnull error, id _Nullable response))failure {
    NSString *svp_path = @"/v1/message/one";
    NSString *svp_tagString;
    if ([SVPDeviceUtils svp_getNeedStill]) {
        svp_tagString = [SVPDeviceUtils svp_getAuthorization];
    }else{
        svp_tagString = @"";
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[SVPDeviceUtils getBundleVersion] forKey:@"app_version"];
    [dic setObject:svp_tagString forKey:@"tag"];
    [SVPInterfaceManager svp_get:svp_path withParams:dic success:^(id  _Nullable response) {
        NSDictionary *resultDic = (NSDictionary *)response;
        SVPScrollMessageModel* svp_model = [[SVPScrollMessageModel alloc]init];
        svp_model.svp_messageTag = [[resultDic objectForKey:@"data"]objectForKey:@"tag"];
        svp_model.svp_messageUrl = [[resultDic objectForKey:@"data"]objectForKey:@"url"];
        svp_model.svp_messageData = [[resultDic objectForKey:@"data"]objectForKey:@"title"];
        success(svp_model);
        } failure:^(NSError * _Nonnull error, id  _Nullable response) {
            failure(error,response);
        }];
}



+ (void)svp_setupSettingInfoSuccess:(void(^)(SVPSettingModel* svp_model))success fail:(void(^)(NSError * _Nonnull error, id _Nullable response))failure {
    NSString *svp_path = @"/v1/account";
    [SVPInterfaceManager svp_post:svp_path withParams:nil success:^(id  _Nullable response) {
        NSString* svp_resultString = [SVPDes decode:[response objectForKey:@"data"] key:[SVPDeviceUtils getDesKeyString]];
        NSDictionary *svp_dic = [SVPDeviceUtils dictionaryWithJsonString:svp_resultString];
        SVPSettingModel *svp_model = [[SVPSettingModel alloc]init];
        svp_model.svp_isVipString = [NSString stringWithFormat:@"%@",[svp_dic objectForKey:@"is_vip"]];
        svp_model.svp_productNameString = [NSString stringWithFormat:@"%@",[svp_dic objectForKey:@"product_name"]];
        svp_model.svp_expirtTimeString = [self getTimeFromTimestamp:[[NSString alloc]initWithFormat:@"%@",[svp_dic objectForKey:@"expired_at"]]];
        success(svp_model);
        } failure:^(NSError * _Nonnull error, id  _Nullable response) {
            failure(error,response);
        }];
}

+ (void)svp_setupCheckAppleOrder {
    NSString *svp_statusString = [SVPLocalDataTool objectForKey:@"receipt"];
    if ([self svp_isCheckNameSpaceString:svp_statusString]) {
        svp_statusString = @"";
    }
    NSString *svp_ticketString = [SVPLocalDataTool objectForKey:@"ticketInformation"];
    if ([self svp_isCheckNameSpaceString:svp_ticketString]) {
        svp_ticketString = @"";
    }
    
    NSString *svp_pathString = @"/v1/order/check/apple";
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[SVPDeviceUtils getIDFA] forKey:@"idfa"];
    [dic setObject:svp_statusString forKey:@"receipt"];
    [dic setObject:svp_ticketString forKey:@"verify_data"];
    [SVPInterfaceManager svp_post:svp_pathString withParams:dic success:^(id  _Nullable response) {
        NSLog(@"order check ----:%@",response);
        } failure:^(NSError * _Nonnull error, id  _Nullable response) {
            NSLog(@"order check error:%@",error);
        }];
}

+ (void)svp_setupTrafficLog:(NSString *)svp_usedTraffic {
    NSString *svp_pathString = @"/v1/log/traffic";
    NSString *svp_stringTag;
    if ([SVPDeviceUtils svp_getNeedStill]) {
        svp_stringTag = [SVPDeviceUtils svp_getAuthorization];
    }else{
        svp_stringTag = @"";
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[SVPDeviceUtils getBundleVersion] forKey:@"app_version"];
    [dic setObject:svp_usedTraffic forKey:@"traffic"];
    [dic setObject:[SVPDeviceUtils getTimeStamp] forKey:@"timestamp"];
    [dic setObject:svp_stringTag forKey:@"tag"];
    
    [SVPInterfaceManager svp_get:svp_pathString withParams:dic success:^(id  _Nullable response) {
        NSLog(@"traffic used %@",response);
        } failure:^(NSError * _Nonnull error, id  _Nullable response) {
            NSLog(@"traffic used error:%@",error);
        }];
}

+ (void)svp_setupSpeedPath:(NSString *)svp_path {
    NSDate *svp_speedDate = [SVPLocalDataTool objectForKey:@"speed"];
    if (svp_speedDate == nil) {
        [SVPLocalDataTool setObject:[self getCurrentTimes] forKey:@"speed"];
    }else{
        //判断日期
        [self compareOneDay:[self getCurrentTimes] withAnotherDay:svp_speedDate pingPath:svp_path];
    }
}

+ (void)svp_setupSpeedLogInfo:(NSDictionary *)svp_dic {
    if (svp_dic == nil) {
        svp_dic = @{@"data":@"null"};
    }
    NSString *svp_WifiString = [NSString stringWithFormat:@"%ld",(long)[SVPDeviceUtils isWifi]];
    NSString *svp_SandboxString = [NSString stringWithFormat:@"%i",[SVPDeviceUtils isSandboxEnvironment]];
    NSString *svp_VPNConnectString = [NSString stringWithFormat:@"%i",[SVPDeviceUtils isVPNConnected]];
    NSString *svp_ProxySetString = [NSString stringWithFormat:@"%i",[SVPDeviceUtils isProxySet]];
    
    NSString *svp_stringTag;
    if ([SVPDeviceUtils svp_getNeedStill]) {
        svp_stringTag = [SVPDeviceUtils svp_getAuthorization];
    }else{
        svp_stringTag = @"null";
    }
    NSMutableDictionary *svp_Dic = [NSMutableDictionary dictionary];
    if (![self svp_isCheckNameSpaceString:[SVPDeviceUtils getBundleVersion]]) {
        [svp_Dic setObject:[SVPDeviceUtils getBundleVersion] forKey:@"app_version"];
    }
    if (![self svp_isCheckNameSpaceString:[SVPDeviceUtils getIDFA]]) {
        [svp_Dic setObject:[SVPDeviceUtils getIDFA] forKey:@"idfa"];
    }
    if (![self svp_isCheckNameSpaceString:[SVPDeviceUtils registrationID]]) {
        [svp_Dic setObject:[SVPDeviceUtils registrationID] forKey:@"push_id"];
    }
    if (![self svp_isCheckNameSpaceString:[SVPDeviceUtils getCurrentLocale]]) {
        [svp_Dic setObject:[SVPDeviceUtils getCurrentLocale] forKey:@"locale"];
    }
    if (![self svp_isCheckNameSpaceString:[SVPDeviceUtils getTimeStamp]]) {
        [svp_Dic setObject:[SVPDeviceUtils getTimeStamp] forKey:@"timestamp"];
    }
    if (![self svp_isCheckNameSpaceString:[SVPDeviceUtils getTimeZone]]) {
        [svp_Dic setObject:[SVPDeviceUtils getTimeZone] forKey:@"timezone"];
    }
    if (![self svp_isCheckNameSpaceString:[SVPDeviceUtils getOsVersion]]) {
        [svp_Dic setObject:[SVPDeviceUtils getOsVersion] forKey:@"system_version"];
    }
    if (![self svp_isCheckNameSpaceString:[SVPDeviceUtils getModel]]) {
        [svp_Dic setObject:[SVPDeviceUtils getModel] forKey:@"device_type"];
    }
    if (![self svp_isCheckNameSpaceString:[SVPDeviceUtils getBundleID]]) {
        [svp_Dic setObject:[SVPDeviceUtils getBundleID] forKey:@"bundle_id"];
    }
    if (![self svp_isCheckNameSpaceString:[SVPDeviceUtils getBundleVersion]]) {
        [svp_Dic setObject:[SVPDeviceUtils getBundleVersion] forKey:@"bundle_version"];
    }
    if (![self svp_isCheckNameSpaceString:[SVPDeviceUtils getCarrierName]]) {
        [svp_Dic setObject:[SVPDeviceUtils getCarrierName] forKey:@"carrier_name"];
    }
    if (![self svp_isCheckNameSpaceString:[SVPDeviceUtils getMobileCountryCode]]) {
        [svp_Dic setObject:[SVPDeviceUtils getMobileCountryCode] forKey:@"mobile_country_code"];
    }
    
    if (![self svp_isCheckNameSpaceString:svp_WifiString]) {
        [svp_Dic setObject:svp_WifiString forKey:@"is_wifi"];
    }
    if (![self svp_isCheckNameSpaceString:svp_SandboxString]) {
        [svp_Dic setObject:svp_SandboxString forKey:@"is_sandbox"];
    }
    if (![self svp_isCheckNameSpaceString:svp_VPNConnectString]) {
        [svp_Dic setObject:svp_VPNConnectString forKey:@"is_vpn_connected"];
    }
    if (![self svp_isCheckNameSpaceString:svp_ProxySetString]) {
        [svp_Dic setObject:svp_ProxySetString forKey:@"is_proxy_set"];
    }
    if (![self svp_isCheckNameSpaceString:svp_stringTag]) {
        [svp_Dic setObject:svp_stringTag forKey:@"tag"];
    }
    [svp_Dic setObject:svp_dic forKey:@"data"];
    NSString *svp_pathString = @"/v1/log/speed";
    [SVPInterfaceManager svp_get:svp_pathString withParams:svp_Dic success:^(id  _Nullable response) {
        NSLog(@"svp_speed------%@",response);
        } failure:^(NSError * _Nonnull error, id  _Nullable response) {
            NSLog(@"error:%@ %@",error,response);
        }];
}


+ (int)compareOneDay:(NSDate *)oneDay withAnotherDay:(NSDate *)anotherDay pingPath:(NSString *)path{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *oneDayStr = [dateFormatter stringFromDate:oneDay];//
    NSString *anotherDayStr = [dateFormatter stringFromDate:anotherDay];//
    NSDate *dateA = [dateFormatter dateFromString:oneDayStr];
    NSDate *dateB = [dateFormatter dateFromString:anotherDayStr];
    NSComparisonResult result = [dateA compare:dateB];
    NSLog(@"date1 : %@, date2 : %@",oneDay, anotherDay);
    if(result == NSOrderedDescending){
        NSLog(@"Date1  is in the future");
        [SVPLocalDataTool setObject:[self getCurrentTimes] forKey:@"speed"];
        NSData *statusData = [SVPLocalDataTool objectForKey:@"ConfigurationV"];
        NSDictionary *userDefaultsDic= [NSKeyedUnarchiver unarchiveObjectWithData:statusData];
        NSString *string = [NSString stringWithFormat:@"http://%@%@",[userDefaultsDic objectForKey:@"ip"],path];
        [STNetMeasure measureForDelay:[userDefaultsDic objectForKey:@"ip"] bandwidth:string finish:^(BOOL success, NSDictionary *result) {
            [self svp_setupSpeedLogInfo:result];
        }];
        
        return 1;
     } else if(result == NSOrderedAscending){
        NSLog(@"没有达到指定日期");
        return -1;
     }
    NSLog(@"两时间相同");
    return 0;
}

+ (void)svp_setupTrailDisable {
    NSString *svp_PathString = @"/v1/account/trial/disable";
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"1" forKey:@"type"];
    [SVPInterfaceManager svp_post:svp_PathString withParams:dic success:^(id  _Nullable response) {
        NSLog(@"Traffic diable:%@",response);
        } failure:^(NSError * _Nonnull error, id  _Nullable response) {
            NSLog(@"error:%@",error);
        }];
}

+ (void)svp_setupLinesCheckService:(NSString *)svp_lineIP VIPType:(NSString *)svp_vipType Status: (void(^)(void))success failure:(void(^)(void))failure {
    NSString *svp_PathString = @"/v1/line/check";
    NSString *svp_stringTag;
    if ([SVPDeviceUtils svp_getNeedStill]) {
        svp_stringTag = [SVPDeviceUtils svp_getAuthorization];
    }else{
        svp_stringTag = @"";
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[SVPDeviceUtils getBundleVersion] forKey:@"app_version"];
    [dic setObject:svp_lineIP forKey:@"ip"];
    [dic setObject:[SVPDeviceUtils getTimeStamp] forKey:@"timestamp"];
    [dic setObject:svp_stringTag forKey:@"tag"];
    [SVPInterfaceManager svp_get:svp_PathString withParams:dic success:^(id  _Nullable response) {
        NSLog(@"lines compare:%@",response);
        success();
        } failure:^(NSError * _Nonnull error, id  _Nullable response) {
            failure();
        }];
}

+ (void)svp_setupLineConnectSuccess:(NSString *)svp_lineIP {
    NSString *svp_PathString = @"/v1/line/success";
    NSString *svp_stringTag;
    if ([SVPDeviceUtils svp_getNeedStill]) {
        svp_stringTag = [SVPDeviceUtils svp_getAuthorization];
    }else{
        svp_stringTag = @"";
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[SVPDeviceUtils getBundleVersion] forKey:@"app_version"];
    [dic setObject:svp_lineIP forKey:@"ip"];
    [dic setObject:[SVPDeviceUtils getTimeStamp] forKey:@"timestamp"];
    [dic setObject:svp_stringTag forKey:@"tag"];
    [SVPInterfaceManager svp_get:svp_PathString withParams:dic success:^(id  _Nullable response) {
        NSLog(@"lines success:%@",response);
        } failure:^(NSError * _Nonnull error, id  _Nullable response) {
            NSLog(@"lines success error:%@",response);
        }];
}

+ (void)svp_setupLineConnectFailure:(NSString *)svp_lineIP {
    NSString *svp_PathString = @"/v1/line/failure";
    NSString *svp_stringTag;
    if ([SVPDeviceUtils svp_getNeedStill]) {
        svp_stringTag = [SVPDeviceUtils svp_getAuthorization];
    }else{
        svp_stringTag = @"";
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[SVPDeviceUtils getBundleVersion] forKey:@"app_version"];
    [dic setObject:svp_lineIP forKey:@"ip"];
    [dic setObject:[SVPDeviceUtils getTimeStamp] forKey:@"timestamp"];
    [dic setObject:svp_stringTag forKey:@"tag"];
    [SVPInterfaceManager svp_get:svp_PathString withParams:dic success:^(id  _Nullable response) {
        NSLog(@"lines failure:%@",response);
        } failure:^(NSError * _Nonnull error, id  _Nullable response) {
            NSLog(@"lines failure error:%@",response);
        }];
}

+ (void)svp_linesSelectRate:(NSString *)svp_lineIP {
    NSString *svp_pathString = @"/v1/line/click";
    NSString *svp_stringTag;
    if ([SVPDeviceUtils svp_getNeedStill]) {
        svp_stringTag = [SVPDeviceUtils svp_getAuthorization];
    }else{
        svp_stringTag = @"";
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[SVPDeviceUtils getBundleVersion] forKey:@"app_version"];
    [dic setObject:svp_lineIP forKey:@"ip"];
    [dic setObject:[SVPDeviceUtils getTimeStamp] forKey:@"timestamp"];
    [dic setObject:svp_stringTag forKey:@"tag"];
    [SVPInterfaceManager svp_get:svp_pathString withParams:dic success:^(id  _Nullable response) {
        NSLog(@"lines select:%@",response);
        } failure:^(NSError * _Nonnull error, id  _Nullable response) {
            NSLog(@"lines select error:%@",response);
        }];
}

+ (BOOL)svp_isCheckNameSpaceString:(NSString *)stringWhite {
    if (!stringWhite) {
        return YES;
    }
    if ([stringWhite isKindOfClass:[NSNull class]]) {
        return YES;
    }
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedStr = [stringWhite stringByTrimmingCharactersInSet:set];
    if (!trimmedStr.length) {
        return YES;
    }
    return NO;
}

+ (NSString *)getTimeFromTimestamp:(NSString *)expired_at{
    double time = [expired_at integerValue];
    NSDate * myDate=[NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter * formatter=[[NSDateFormatter alloc]init];
    //    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *timeStr = [formatter stringFromDate:myDate];
    return timeStr;
}

+(NSDate*)getCurrentTimes{
    NSDateFormatter *currentDate = [[NSDateFormatter alloc]init];
    [currentDate setDateFormat:@"dd-MM-yyyy"];
    NSDate *datenow = [NSDate date];
    return datenow;
}
@end
