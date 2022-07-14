//
//  SVPInterfaceManager.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/8.
//

#import "SVPInterfaceManager.h"
#import "AFHTTPSessionManager.h"
#import "SVPDeviceUtils.h"
#import "MBProgressManager.h"

@implementation SVPInterfaceManager

+ (void)svp_request:(NSString *)svp_path isPost:(BOOL)svp_isPost withParams:(NSDictionary * _Nullable)params success:(void (^)(id _Nullable response))success failure:(void (^)(NSError * _Nonnull error, id _Nullable response))failure {
    NSDictionary *svp_headerDic = @{@"source":[SVPDeviceUtils getBundleID],@"language":[SVPDeviceUtils getLanguage],@"activate_id":[SVPDeviceUtils getKeychainSavedString],@"app_version":[SVPDeviceUtils getBundleVersion]};
    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
    AFHTTPRequestSerializer *requestSerializer =  [AFJSONRequestSerializer serializer];
    
    for (NSString *httpHeaderField in svp_headerDic.allKeys) {
        NSString *value = svp_headerDic[httpHeaderField];
        [requestSerializer setValue:value forHTTPHeaderField:httpHeaderField];
    }
    NSDictionary *svp_baseParams = @{
                                 @"source": [SVPDeviceUtils getBundleID],
                                 @"language":[SVPDeviceUtils getLanguage],
                                 @"activate_id":[SVPDeviceUtils getKeychainSavedString],
                                 };
    NSMutableDictionary *URLParameters = [svp_baseParams mutableCopy];
    if (params) {
        for (NSString *paramKey in params) {
            URLParameters[paramKey] = params[paramKey];
        }
    }
    manger.requestSerializer = requestSerializer;
    NSString *fullPath = [NSString stringWithFormat:@"%@%@",[SVPDeviceUtils svp_HTTPPATH], svp_path];
    if (svp_isPost) {
        [manger POST:fullPath parameters:URLParameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSString *status = [[NSString alloc]initWithFormat:@"%@",[responseObject objectForKey:@"status"]];
            if ([status isEqualToString:@"1"]) {
                if (success) {
                    success(responseObject);
                }
            }else {
                if (failure) {
                    NSLog(@"error status response");
                    id statusInfo = status;
                    if (!statusInfo) {
                        statusInfo = @"empty";
                    }
                    failure([NSError errorWithDomain:NSURLErrorDomain code:1 userInfo:@{@"status": statusInfo}], responseObject);
                }
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (failure) {
                failure(error, nil);
            }
        }];
    }else {
        [manger GET:fullPath parameters:URLParameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSString *status = [[NSString alloc]initWithFormat:@"%@",[responseObject objectForKey:@"status"]];
            if ([status isEqualToString:@"1"]) {
                if (success) {
                    success(responseObject);
                }
            }else {
                if (failure) {
                    NSLog(@"error status response");
                    id statusInfo = status;
                    if (!statusInfo) {
                        statusInfo = @"empty";
                    }
                    failure([NSError errorWithDomain:NSURLErrorDomain code:1 userInfo:@{@"status": statusInfo}], responseObject);
                    NSLog(@"%@  %@",responseObject,URLParameters);
                }
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (failure) {
                failure(error, nil);
            }
        }];
    }
}

+ (void)svp_get:(NSString *)svp_path withParams:(NSDictionary *)params success:(void (^)(id _Nullable))success failure:(void (^)(NSError * _Nonnull, id _Nullable))failure {
    [self svp_request:svp_path isPost:NO withParams:params success:success failure:failure];
}

+ (void)svp_post:(NSString *)svp_path withParams:(NSDictionary *)params success:(void (^)(id _Nullable))success failure:(void (^)(NSError * _Nonnull, id _Nullable))failure {
    [self svp_request:svp_path isPost:YES withParams:params success:success failure:failure];
}
@end
