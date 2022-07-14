//
//  SVPInterfaceManager.h
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SVPInterfaceManager : NSObject
+ (void)svp_get:(NSString *)svp_path withParams:(NSDictionary *_Nullable)params success:(void (^)(id _Nullable response))success failure:(void (^)(NSError * _Nonnull error, id _Nullable response))failure;
+ (void)svp_post:(NSString *)svp_path withParams:(NSDictionary *_Nullable)params success:(void (^)(id _Nullable response))success failure:(void (^)(NSError * _Nonnull error, id _Nullable response))failure ;
@end

NS_ASSUME_NONNULL_END
