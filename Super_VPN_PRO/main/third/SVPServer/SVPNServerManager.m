//
//  SVPNManager.m
//  SPVPN
//
//  Created by LC on 2022/4/13.
//

#import "SVPNServerManager.h"

static SVPNServerManager * manager = nil;

static NSString* PACKETTUNNEL_BUNDLE_ID = @"com.superoversea.PacketTunnel";

@interface SVPNServerManager()

// 隧道
@property (nonatomic, strong) NETunnelProviderManager* tunnel;

@end

@implementation SVPNServerManager

// 单例
+ (instancetype)shareInstance {
    if (manager == nil) {
        manager = [[SVPNServerManager alloc] init];//调用自己改写的”私有构造函数“
    }
    return manager;
}

//相当于将构造函数设置为私有，类的实例只能初始化一次
+ (id) allocWithZone:(struct _NSZone*)zone
{
    if (manager == nil) {
        manager = [super allocWithZone:zone];
        [manager setup];
    }
    return manager;
}

//重写copy方法中会调用的copyWithZone方法，确保单例实例复制时不会重新创建
- (id) copyWithZone:(struct _NSZone *)zone
{
    return manager;
}

// 初始化
- (void) setup {
    self.status = NEVPNStatusDisconnected;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateStatus)
                                                 name:NEVPNStatusDidChangeNotification
                                               object:nil];
    
    // 初始化配置状态
    [NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(NSArray<NETunnelProviderManager *> * _Nullable managers, NSError * _Nullable error) {
        BOOL isExistConfig = NO;
        for (NETunnelProviderManager* manager in managers) {
            NETunnelProviderProtocol* protocol = (NETunnelProviderProtocol*)manager.protocolConfiguration;
            if (protocol&&[protocol.providerBundleIdentifier isEqual:PACKETTUNNEL_BUNDLE_ID]) {
                isExistConfig = YES;
                break;
            }
        }
//        self.isInstallerVPNConfig = isExistConfig;
    }];
}

// 添加配置
- (void)installConfigure:(void(^)(NSError* error))complete {
    __weak typeof(self) weakSelf = self;
    [self loadTunnelConfigure:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (error) {
            complete(error);
            return;
        }
        
        // 保存
        [strongSelf saveToPreferences:^(NSError *error) {
            [self.tunnel saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
                if (error) {
                    complete(error);
                    return;
                }
            }];
        }];
        
    }];
}

// 下载配置
- (void)loadTunnelConfigure:(void(^)(NSError *error))complete {
    [NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(NSArray<NETunnelProviderManager *> * _Nullable managers, NSError * _Nullable error) {
//        BOOL isInstallConfigured = NO;
        for (NETunnelProviderManager * manager in managers) {
            NETunnelProviderProtocol * protocol = (NETunnelProviderProtocol*)manager.protocolConfiguration;
            if (protocol && [protocol.providerBundleIdentifier isEqualToString:PACKETTUNNEL_BUNDLE_ID]) {
                self.tunnel = manager;
//                isInstallConfigured = YES;
            }
        }
        if (!self.tunnel) {
            NETunnelProviderManager * manager = [[NETunnelProviderManager alloc] init];
            NETunnelProviderProtocol * protocol = [[NETunnelProviderProtocol alloc] init];
            protocol.providerBundleIdentifier = PACKETTUNNEL_BUNDLE_ID;
            protocol.serverAddress = @"VPN";
            manager.protocolConfiguration = protocol;
            manager.localizedDescription = @"VPN";
            manager.enabled = YES;
            self.tunnel = manager;
        }
        self.tunnel.enabled = YES;
        complete(error);
    }];
}

// 保存配置文件
- (void) saveToPreferences:(void(^)(NSError* error))completion {
    [self.tunnel saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        completion(error);
    }];
}

// 开启隧道
- (void)startVPN:(nullable NSDictionary<NSString *,NSObject *> *)options completion:(void(^)(NSError* error)) completion {
    __weak typeof(self) weakSelf = self;
    [self loadTunnelConfigure:^(NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (error) {
            completion(error);
            return;
        }

        // 保存
        [strongSelf saveToPreferences:^(NSError *error) {
            if (error) {
                completion(error);
                return;
            }

            [strongSelf.tunnel loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
                NSError *returnError;
                [strongSelf.tunnel.connection startVPNTunnelWithOptions:options andReturnError:&returnError];
                completion(returnError);
            }];
        }];
    }];
}

// 关闭隧道
- (void)stopVPN {
    if (self.tunnel) {
        [self.tunnel.connection stopVPNTunnel];
    }
}

- (void)updateStatus {
    NSInteger oldStatu = self.status;
    if (self.tunnel) {
        self.status = self.tunnel.connection.status;
    }
    
    if (oldStatu != self.status) {
        if (self.connectionStatusHandler) {
            self.connectionStatusHandler(self.status);
        }
    }

    switch (self.status) {
        case 0:
            NSLog(@"未配置 VPN");
            break;

        case 1:
            NSLog(@"VPN已断开连接");
            break;

        case 2:
            NSLog(@"VPN 正在连接");
            break;

        case 3:
            NSLog(@"VPN 已连接");
            break;

        case 4:
            NSLog(@"VPN 正在重新连接");
            break;

        case 5:
            NSLog(@"VPN 正在断开连接");
            break;

        default:
            break;
    }
}

@end
