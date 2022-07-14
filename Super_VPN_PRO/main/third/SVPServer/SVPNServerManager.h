//
//  SVPNManager.h
//  SPVPN
//
//  Created by LC on 2022/4/13.
//

#import <Foundation/Foundation.h>
#import <NetworkExtension/NetworkExtension.h>

NS_ASSUME_NONNULL_BEGIN


@interface SVPNServerManager : NSObject

// 状态
@property (nonatomic, assign) NEVPNStatus status;

@property (nonatomic, copy) void(^connectionStatusHandler)(NEVPNStatus status);

// 单例
+ (instancetype)shareInstance;

// 开启隧道
- (void)startVPN:(nullable NSDictionary<NSString *,NSObject *> *)options completion:(void(^)(NSError* error)) completion;

// 关闭隧道
- (void)stopVPN;

// 添加配置
- (void)installConfigure:(void(^)(NSError* error))complete;

@end

NS_ASSUME_NONNULL_END
