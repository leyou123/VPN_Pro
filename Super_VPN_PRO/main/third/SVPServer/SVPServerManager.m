//
//  SVPServerManager.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/15.
//

#import "SVPServerManager.h"
#import "SVPServerConnection.h"
#import "SVPServerConnectivity.h"

static NSString * kSVPServerMessageKeyAction = @"action";
static NSString * kSVPServerMessageKeyConnectionId = @"connectionId";
static NSString * kSVPServerMessageKeyTotalDataFlow = @"totalDataFlow";
static NSString * kSVPServerMessageKeyConfig = @"config";
static NSString * kSVPServerMessageKeyErrorCode = @"errorCode";
static NSString * kSVPServerMessageKeyHost = @"host";
static NSString * kSVPServerMessageKeyPort = @"port";
static NSString * kSVPServerMessageKeyIsOnDemand = @"is-on-demand";
static NSString * kSVPServerMessageKeySetLimit = @"setLimitMsg";


static NSString * kSVPServerActionStart = @"start";
static NSString * kSVPServerActionRestart = @"restart";
static NSString * kSVPServerActionStop = @"stop";
static NSString * kSVPServerActionGetConnectionId = @"getConnectionId";
static NSString * kSVPServerActionIsReachable = @"isReachable";
static NSString * kSVPServerActionTotalDataFlow = @"totalDataFlow";
static NSString * kSVPServerActionSetLimit = @"setLimitAction";

static SVPServerManager *sharedInstance;

@interface SVPServerManager()
@property (strong, nonatomic)NSString *activeConnectionId;
@property (strong, nonatomic)NETunnelProviderManager *svp_tunnelManager;
@property (strong, nonatomic)NSString *svpServerExtensionBundelID;
@property (strong, nonatomic)SVPServerConnectivity *connectivity;

@end

@implementation SVPServerManager

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (sharedInstance == nil) {
        @synchronized(self) {
            if (sharedInstance == nil) {
                sharedInstance = [super allocWithZone:zone];
            }
        }
    }
    return sharedInstance;
}

+ (instancetype)shared {
    if (sharedInstance == nil) {
        @synchronized(self) {
            if (sharedInstance == nil) {
                sharedInstance = [[self alloc] init];
                sharedInstance.svpServerExtensionBundelID = [NSString stringWithFormat:@"%@.PacketTunnel", NSBundle.mainBundle.bundleIdentifier];
                sharedInstance.connectivity = [[SVPServerConnectivity alloc] init];
                [sharedInstance getTunnelManager:^(NETunnelProviderManager *manager) {
                    if (!manager) {
                        return NSLog(@"Tunnel manager not active. VPN not configured.");
                    }
                    sharedInstance.svp_tunnelManager = manager;
                    [sharedInstance observeSvpServerStatusChange:sharedInstance.svp_tunnelManager];
                    if ([sharedInstance isSvpServerConnected]) {
                        [sharedInstance retrieveActiveConnectionId];
                    }
                }];
            }
        }
    }
    return sharedInstance;
}

- (id)copyWithZone:(NSZone *)zone{
    return sharedInstance;
}

- (void)svp_start:(SVPServerConnection *)connection completion:(void(^)(SVPServerErrorCode))completion {
    NSString *svp_connectionId = connection.serverID;
//    svp_connectionId = @"server002";
//    connection.serverID = svp_connectionId;
//    if (!svp_connectionId) {
//        NSLog(@"Missing connection ID:缺少连接ID");
//        return completion(SVPServerErrorCodeIllegalServerConfiguration);
//    }
//    if ([self svp_isActive:svp_connectionId]) {
//        NSLog(@"vpn already active:vpn已经激活");
//        return completion(SVPServerErrorCodeNoError);
//    }else if ([self isSvpServerConnected]) {
//        NSLog(@"vpn already connected, restarting:vpn已连接，正在重启");
//        [self svp_restart:svp_connectionId config:connection.config completion:completion];
//        return;
//    }
    [self svp_start:connection isAutoConnect:NO completion:completion];
}

- (void)svp_start:(SVPServerConnection *)connection isAutoConnect:(BOOL)isAutoConnect completion:(void(^)(SVPServerErrorCode))completion {
    NSString *svp_connectionId = connection.serverID == nil ? @"" : connection.serverID;
    [self svp_setupSVPServer:^(NSError *error) {
        if (error) {
            NSLog(@"Failed to setup VPN: %@", error);
            return completion(SVPServerErrorCodeVpnPermissionNotGranted);
        }
        NSDictionary *message = @{
            kSVPServerMessageKeyAction: kSVPServerActionStart,
            kSVPServerMessageKeyConnectionId: svp_connectionId,
        };
        [self sendSvpServerExtensionMessage:message callback:^(NSDictionary *response) {
            [self onStartSvpServerExtensionMessage:response completion:completion];
        }];
        NSMutableDictionary *config;
        if (!isAutoConnect) {
            config = [connection.config mutableCopy];
            config[kSVPServerMessageKeyConnectionId] = svp_connectionId;
        }else {
            // macOS app was started by launcher.
            config = [@{kSVPServerMessageKeyIsOnDemand: @"true"} mutableCopy];
        }
//        NETunnelProviderSession *session = (NETunnelProviderSession *)self.svp_tunnelManager.connection;
//        NSError *err;
//        [session startTunnelWithOptions:config andReturnError:&err];
//        if (err) {
//            NSLog(@"Failed to start VPN: %@",err);
//            completion(SVPServerErrorCodeVpnStartFailure);
//        }
        NSError *returnError;
        NSDictionary * dic = @{@"password":@"EF14C996-DEB9-4750-96BB-6C1DA01AADA9",@"host":@"tj1925.9527.click",@"port":@"443",@"remainMins":@"4301"};
        [self.svp_tunnelManager.connection startVPNTunnelWithOptions:dic andReturnError:&returnError];
        completion(SVPServerErrorCodeVpnStartFailure);
    }];
}

// Sends message to extension to restart the tunnel without tearing down the VPN.
- (void)svp_restart:(NSString *)connectionId config:(NSDictionary *)config completion:(void(^)(SVPServerErrorCode))completion {
    if (self.activeConnectionId) {
        if (self.svpServerStatusObserver) {
            self.svpServerStatusObserver(NEVPNStatusDisconnected, self.activeConnectionId);
        }
    }
    NSDictionary *message = @{
        kSVPServerMessageKeyAction: kSVPServerActionRestart,
        kSVPServerMessageKeyConnectionId: connectionId,
        kSVPServerMessageKeyConfig: config,
    };
    [self sendSvpServerExtensionMessage:message callback:^(NSDictionary *response) {
        [self onStartSvpServerExtensionMessage:response completion:completion];
    }];
}

- (void)svp_stop:(NSString *)connectionId {
    if (![self svp_isActive:connectionId]) {
        return NSLog(@"Cannot stop VPN, connection ID %@",connectionId);
    }
    NETunnelProviderSession *seccion = (NETunnelProviderSession *)self.svp_tunnelManager.connection;
    [seccion stopTunnel];
    [self setConnectSvpServerOnDemand:NO];
    self.activeConnectionId = nil;
}

- (BOOL)svp_isActive:(NSString *)connectionId {
    if (!self.activeConnectionId) {
        return false;
    }
    return [self.activeConnectionId isEqualToString:connectionId] && [self isSvpServerConnected];
}

- (void)svp_isReachable:(SVPServerConnection *)connection completion:(void(^)(SVPServerErrorCode))completion {
    NSString *host = connection.host;
    uint16_t port = (uint16_t)[connection.port intValue];
    if (!host || !port) {
        return NSLog(@"Missing host or port argument");
    }
    if ([self isSvpServerConnected]) {
        // All the device's traffic, including the NetworkPlugin app, go through the VpnExtension process.
        // Performing a reachability test, opening a TCP socket to a host/port, will succeed
        // unconditionally as the request will not leave the device. Send a message to the
        // VpnExtension process to perform the reachability test.
        NSDictionary *message = @{
            kSVPServerMessageKeyAction: kSVPServerActionIsReachable,
            kSVPServerMessageKeyHost: host,
            kSVPServerMessageKeyPort: [NSNumber numberWithInt:port],
        };
        
        [self sendSvpServerExtensionMessage:message callback:^(NSDictionary *response) {
            if (!response) {
                return completion(SVPServerErrorCodeServerUnreachable);
            }
            completion([response[kSVPServerMessageKeyErrorCode] intValue]);
        }];
    }else {
        [self.connectivity isServerReachable:host port:port completion:^(BOOL isReachable) {
            completion(isReachable ? SVPServerErrorCodeNoError : SVPServerErrorCodeServerUnreachable);
        }];
    }
}

- (BOOL)isSvpServerConnected {
    if (!self.svp_tunnelManager) {
        return NO;
    }
    NEVPNStatus status = self.svp_tunnelManager.connection.status;
    return status == NEVPNStatusConnected || status == NEVPNStatusConnecting || status == NEVPNStatusReasserting;
}

- (void)setConnectSvpServerOnDemand:(BOOL)flag {
    self.svp_tunnelManager.onDemandEnabled = flag;
    [self.svp_tunnelManager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Failed to set VPN on demand to %d: %@", flag, error);
        }
    }];
}

// Adds a VPN configuration to the user preferences if no NetworkPlugin profile is present. Otherwise
// enables the existing configuration.
- (void)svp_setupSVPServer:(void(^)(NSError *))completion {
    [NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(NSArray<NETunnelProviderManager *> * _Nullable managers, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Failed to load VPN configuration: %@",error);
            return completion(error);
        }
        NETunnelProviderManager *manager;
        if (managers.count > 0) {
            manager = managers.firstObject;
            BOOL hasOnDemandRules = manager.onDemandRules.count > 0;
            if (manager.isEnabled && hasOnDemandRules) {
                self.svp_tunnelManager = manager;
                return completion(nil);
            }
        }else {
            NETunnelProviderProtocol *config = [[NETunnelProviderProtocol alloc] init];
            config.providerBundleIdentifier = self.svpServerExtensionBundelID;
            config.serverAddress = @"extension";
            manager = [[NETunnelProviderManager alloc] init];
            manager.protocolConfiguration = config;
        }
        NEOnDemandRuleConnect *connectRule = [[NEOnDemandRuleConnect alloc] init];
        connectRule.interfaceTypeMatch = NEOnDemandRuleInterfaceTypeAny;
        //manager.onDemandRules = @[connectRule];
        manager.onDemandRules = nil;
        manager.enabled = YES;
        [manager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"Failed to save VPN configuration: %@",error);
                return completion(error);
            }
            [self observeSvpServerStatusChange:manager];
            self.svp_tunnelManager = manager;
            [NSNotificationCenter.defaultCenter postNotificationName:NEVPNConfigurationChangeNotification object:nil];
            [self.svp_tunnelManager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
                completion(error);
            }];
        }];
    }];
}

- (void)observeSvpServerStatusChange:(NETunnelProviderManager *)manager {
    // Listen for changes in the VPN status.
    // Remove self to guard against receiving duplicate notifications due to page reloads.
    [NSNotificationCenter.defaultCenter removeObserver:self name:NEVPNStatusDidChangeNotification object:manager.connection];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(svpServerStatusChanged) name:NEVPNStatusDidChangeNotification object:manager.connection];
}

- (void)getTunnelManager:(void(^)(NETunnelProviderManager *))completion {
    [NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(NSArray<NETunnelProviderManager *> * _Nullable managers, NSError * _Nullable error) {
        if (error || !managers) {
            completion(nil);
            return NSLog(@"Failed to get tunnel manager: %@",error);
        }
        completion(managers.firstObject);
    }];
}

- (void)svpServerStatusChanged {
    if (self.svp_tunnelManager) {
        NEVPNStatus vpnStatus = self.svp_tunnelManager.connection.status;
        if (self.activeConnectionId) {
            if (vpnStatus == NEVPNStatusDisconnected) {
                self.activeConnectionId = nil;
            }
            if (self.svpServerStatusObserver) {
                self.svpServerStatusObserver(vpnStatus, self.activeConnectionId);
            }
        }else if (vpnStatus == NEVPNStatusConnected) {
            // The VPN was connected from the settings app while the UI was in the background.
            // Retrieve the connection ID to update the UI.
            [self retrieveActiveConnectionId];
        }
    }
}

- (void)retrieveActiveConnectionId {
    if (!self.svp_tunnelManager) {
        return;
    }
    [self sendSvpServerExtensionMessage:@{kSVPServerMessageKeyAction:kSVPServerActionGetConnectionId} callback:^(NSDictionary *response) {
        if (!response) {
            return NSLog(@"Failed to retrieve the active connection ID");
        }
        NSString *activeConnectionId = response[kSVPServerMessageKeyConnectionId];
        if (!activeConnectionId) {
            return NSLog(@"Failed to retrieve the active connection ID");
        }
        NSLog(@"Got active connection ID: %@", activeConnectionId);
        self.activeConnectionId = activeConnectionId;
        if (self.svpServerStatusObserver) {
            self.svpServerStatusObserver(NEVPNStatusConnected, self.activeConnectionId);
        }
    }];
}

// MARK: VPN extension IPC

/**
 Sends a message to the VPN extension if the VPN has been setup. Sets a
 callback to be invoked by the extension once the message has been processed.
 */
- (void)sendSvpServerExtensionMessage:(NSDictionary *)message callback:(void(^)(NSDictionary *))callback {
    if (!self.svp_tunnelManager) {
        return NSLog(@"Cannot set an extension callback without a tunnel manager");
    }
    NSError *err;
    NSData *data = [NSJSONSerialization dataWithJSONObject:message options:0 error:&err];
    if (err) {
        return NSLog(@"Failed to serialize message to VpnExtension as JSON");
    }
    NETunnelProviderSession *session = (NETunnelProviderSession *)self.svp_tunnelManager.connection;
    [session sendProviderMessage:data returnError:&err responseHandler:^(NSData * _Nullable responseData) {
        if (!responseData) {
            return callback(nil);
        }
        NSError *err;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&err];
        if (err) {
            callback(nil);
            NSLog(@"Failed to deserialize the VpnExtension response");
        }
        NSLog(@"Received extension message: %@",response);
        callback(response);
    }];
    if (err) {
        return NSLog(@"Failed to send message to VpnExtension");
        //TODO 错误了还走不走回调?
        return callback(nil);
    }
}

- (void)onStartSvpServerExtensionMessage:(NSDictionary *)message completion:(void(^)(SVPServerErrorCode))completion {
    if (!message) {
        return completion(SVPServerErrorCodeVpnStartFailure);
    }
    SVPServerErrorCode errorCode = [message[kSVPServerMessageKeyErrorCode] intValue];
    if (errorCode == SVPServerErrorCodeNoError) {
        NSString *connectionId = message[kSVPServerMessageKeyConnectionId];
        self.activeConnectionId = connectionId;
        [self setConnectSvpServerOnDemand:YES];
    }
    completion(errorCode);
}

- (void)svp_getTotalDataFlow:(void(^)(long totalBytes))completion{
    [self sendSvpServerExtensionMessage:@{kSVPServerMessageKeyAction:kSVPServerActionTotalDataFlow} callback:^(NSDictionary *response) {
        if (!response) {
            completion(-1);
            return NSLog(@"Failed to retrieve total data flow");
        }
        NSString *total = response[kSVPServerMessageKeyTotalDataFlow];
        completion(total.integerValue);
    }];
}

- (void)svp_setDataFlowLimit:(long)total completion:(void(^)(NSDictionary *response))completion{
    [self sendSvpServerExtensionMessage:@{kSVPServerMessageKeyAction:kSVPServerActionSetLimit, kSVPServerMessageKeySetLimit:[NSNumber numberWithLong:total]} callback:^(NSDictionary *response) {
        if (!response) {
            completion(@{@"error": @"Failed to set total data flow limit"});
            return NSLog(@"Failed to set total data flow limit");
        }
        completion(response);
    }];
}
@end
