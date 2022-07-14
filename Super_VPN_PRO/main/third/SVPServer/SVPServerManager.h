//
//  SVPServerManager.h
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/15.
//

#import <Foundation/Foundation.h>
#import <NetworkExtension/NetworkExtension.h>
NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    SVPServerErrorCodeNoError,
    SVPServerErrorCodeUndefined,
    SVPServerErrorCodeVpnPermissionNotGranted,
    SVPServerErrorCodeInvalidServerCredentials,
    SVPServerErrorCodeUdpRelayNotEnabled,
    SVPServerErrorCodeServerUnreachable,
    SVPServerErrorCodeVpnStartFailure,
    SVPServerErrorCodeIllegalServerConfiguration,
    SVPServerErrorCodeShadowsocksStartFailure,
    SVPServerErrorCodeConfigureSystemProxyFailure,
    SVPServerErrorCodeNoAdminPermissions,
    SVPServerErrorCodeUnsupportedRoutingTable,
    SVPServerErrorCodeSystemMisconfigured,
} SVPServerErrorCode;

@class SVPServerConnection;
@interface SVPServerManager : NSObject
@property (strong, nonatomic)void(^svpServerStatusObserver)(NEVPNStatus, NSString *);

+ (instancetype)shared;
- (void)svp_start:(SVPServerConnection *)connection completion:(void(^)(SVPServerErrorCode))completion;
- (void)svp_restart:(NSString *)connectionId config:(NSDictionary *)config completion:(void(^)(SVPServerErrorCode))completion;
- (void)svp_stop:(NSString *)connectionId;
- (BOOL)svp_isActive:(NSString *)connectionId;
- (void)svp_isReachable:(SVPServerConnection *)connection completion:(void(^)(SVPServerErrorCode))completion;
- (NSString *)activeConnectionId;
//异步获取本次安装已经使用的流量字节总量
- (void)svp_getTotalDataFlow:(void(^)(long totalBytes))completion;
//设置流量限制,超出后自动限流,如果不限制传-1
- (void)svp_setDataFlowLimit:(long)total completion:(void(^)(NSDictionary *response))completion;
- (void)svp_setupSVPServer:(void(^)(NSError *))completion;



// 开启隧道
- (void) start:(nullable NSDictionary<NSString *,NSObject *> *)options completion:(void(^)(NSError* error)) completion;

@end

NS_ASSUME_NONNULL_END
