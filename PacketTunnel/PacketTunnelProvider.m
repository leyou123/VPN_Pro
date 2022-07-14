//
//  SVPPacketTunnelProvider.m
//  PacketTunnel
//
//  Created by MacOSDaye on 2021/9/22.
//
#import <PacketProcessor_iOS/TunnelInterface.h>
#import "PacketTunnelProvider.h"

#import "SVPServerConnection.h"
#import "SVPServerConnectionStore.h"
#import "SVPServiceSubnet.h"
#import "SVPServiceTrafficMeter.h"
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <netdb.h>
#include <sys/socket.h>
//#import "Shadowsocks.h"
#import "ShadowsocksConnectivity.h"
#import "libleaf/leaf.h"
#import "PacketTunnel-Swift.h"
#import "dns.h"

NSString *const SVPActionStart = @"start";
NSString *const SVPActionRestart = @"restart";
NSString *const SVPActionStop = @"stop";
NSString *const SVPActionGetConnectionId = @"getConnectionId";
NSString *const SVPActionIsReachable = @"isReachable";
NSString *const SVPActionTotalDataFlow = @"totalDataFlow";
NSString *const SVPActionTotalSetLimit = @"setLimitAction";
NSString *const SVPMessageKeyAction = @"action";
NSString *const SVPMessageKeyConnectionId = @"connectionId";
NSString *const SVPMessageKeyConfig = @"config";
NSString *const SVPMessageKeyErrorCode = @"errorCode";
NSString *const SVPMessageKeyHost = @"host";
NSString *const SVPMessageKeyPort = @"port";
NSString *const SVPMessageKeyOnDemand = @"is-on-demand";
NSString *const SVPMessageKeyTotalDataFlow = @"totalDataFlow";
NSString *const SVPMessageKeySetLimit = @"setLimitMsg";

NSString *const kDefaultPathKey = @"defaultPath";
static NSDictionary *kSVPSubnetCandidates;
#define RL_ID 2211

@interface PacketTunnelProvider ()

//@property (strong, nonatomic)Shadowsocks *svp_ShadowSocks;
@property (strong, nonatomic)ShadowsocksConnectivity *svp_ShadowsConnectivity;

@property (nonatomic) NSString *hostNetworkAddress;  // IP address of the host in the active network.
@property (nonatomic) NSString *dnsNetworkAddress;

@property (nonatomic) NSString *pingSubnetFree;  // IP address of the host in the active network.
@property (nonatomic) NSString *pingSubnetVIP;

@property (nonatomic) BOOL isTunnelConnected;

@property (nonatomic, copy) void (^startCompletion)(NSNumber *);
@property (nonatomic, copy) void (^stopCompletion)(NSNumber *);

@property (nonatomic) SVPServerConnection *svp_connection;
@property (nonatomic) SVPServerConnectionStore *svp_connectionStore;

@property(nonatomic, assign) int leaf_id;
@property(nonatomic, copy) void (^completionHandler)(NSError *);
@property(nonatomic, copy) void (^stopCompletionHandler)(void);
@property(nonatomic, strong) NSTimer* timer;
@property(nonatomic, strong) NSDictionary *options;
@property(nonatomic, assign) NEProviderStopReason stopReason;

@end

@implementation PacketTunnelProvider

- (id)init {
    self = [super init];
    NSString *appGroup = [[NSString alloc] initWithFormat:@"group.%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"]];
      NSLog(@"~~~%@",appGroup);
    self.svp_connectionStore = [[SVPServerConnectionStore alloc] initWithAppGroup:appGroup];
      
    kSVPSubnetCandidates = @{
      @"10" : @"10.111.222.0",
      @"172" : @"172.16.9.1",
      @"192" : @"192.168.20.1",
      @"169" : @"169.254.19.0"
    };

    return self;
}

- (void)startTunnelWithOptions:(NSDictionary *)options
             completionHandler:(void (^)(NSError *))completionHandler {
    if (options == nil) {
    NSString *msg = NSLocalizedStringWithDefaultValue(
        @"vpn-connect", @"NetworkPlugin", [NSBundle mainBundle],
        @"Please use the NetworkPlugin app to connect.",
        @"Message shown in a system dialog when the user attempts to connect from settings");
    [self displayMessage:msg
        completionHandler:^(BOOL success) {
          completionHandler([NSError errorWithDomain:NEVPNErrorDomain
                                                code:NEVPNErrorConfigurationDisabled
                                            userInfo:nil]);
          exit(0);
        }];
    return;
    }

    self.options = options;
    self.leaf_id = RL_ID;
    self.completionHandler = completionHandler;
    self.stopReason = NEProviderStopReasonNone;

    //     判断
    NSInteger seconds = [[[NSUserDefaults standardUserDefaults] objectForKey:@"REMAINMINS"] integerValue] * 60;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        leaf_shutdown(RL_ID);
        self.leaf_id = -1;
        exit(0);
    });
    //开启隧道代理
    [self starTrojanProxy:options];
    
    return;

    SVPServerConnection *connection = [self retrieveConnection:options];
    if (connection == nil) {
    completionHandler([NSError errorWithDomain:NEVPNErrorDomain
                                          code:NEVPNErrorConfigurationUnknown
                                      userInfo:nil]);
    return;
    }
    self.svp_connection = connection;

    // Compute the IP address of the host in the active network.
    self.hostNetworkAddress = [self getNetworkIpAddress:[self.svp_connection.config[@"host"] UTF8String]];
    self.dnsNetworkAddress = [self getNetworkIpAddress:[self.svp_connection.config[@"dns"] UTF8String]];
    self.pingSubnetFree = self.svp_connection.config[@"pingSubnetFree"];
    self.pingSubnetVIP = self.svp_connection.config[@"pingSubnetVIP"];

    if (self.hostNetworkAddress == nil) {
    [self execAppCallbackForAction:SVPActionStart errorCode:svp_illegalServerConfiguration];
    return completionHandler([NSError errorWithDomain:NEVPNErrorDomain
                                                 code:NEVPNErrorConfigurationReadWriteFailed
                                             userInfo:nil]);
    }
//  bool isOnDemand = options[SVPMessageKeyOnDemand] != nil;
//  NSLog(@"isOnDemand %d", isOnDemand);
//  self.svp_ShadowSocks = [[Shadowsocks alloc]init:[self getShadowsocksNetworkConfig]];
//  [self.svp_ShadowSocks
//      startWithConnectivityChecks:!isOnDemand
//                       completion:^(ErrorCode errorCode) {
//                         ErrorCode clientErrorCode =
//                             (errorCode == svp_noError || errorCode == svp_udpRelayNotEnabled) ? svp_noError
//                                                                                       : errorCode;
//                         if (clientErrorCode == svp_noError) {
//                             [SVPServiceTrafficMeter start_SVPRecordTraffic];
//                           NSLog(@"StartWithConnectivityChecks noError %ld", errorCode);
//                             [self repeatCheckLimit];
//                           [self connectTunnel:[self getTunnelNetworkSettings]
//                                    completion:^(NSError *error) {
//                                      if (!error) {
//                                        BOOL isUdpSupported =
//                                          isOnDemand ? self.svp_connectionStore.isUdpSupported
//                                                       : errorCode == svp_noError;
//                                        NSLog(@"StartWithConnectivityChecks udp %d", isUdpSupported);
//                                        [self setupPacketTunnelFlow];
//                                        [TunnelInterface setIsUdpForwardingEnabled:isUdpSupported];
//                                        [self startTun2SocksWithPort:kShadowsocksLocalPort];
//                                          [self execAppCallbackForAction:SVPActionStart
//                                                             errorCode:svp_noError];
//                                        // Listen for network changes.
//                                        [self addObserver:self
//                                               forKeyPath:kDefaultPathKey
//                                                  options:NSKeyValueObservingOptionOld
//                                                  context:nil];
//
//                                          [self.svp_connectionStore save:connection];
//                                          self.svp_connectionStore.isUdpSupported = isUdpSupported;
//                                          self.svp_connectionStore.status = SVPServerConnectionStatusConnected;
//
//                                      } else {
//                                        [self execAppCallbackForAction:SVPActionStart
//                                                             errorCode:svp_vpnPermissionNotGranted];
//                                      }
//                                      completionHandler(error);
//                                    }];
//                         } else {
//                           NSLog(@"StartWithConnectivityChecks Error %ld", errorCode);
//                             [self execAppCallbackForAction:SVPActionStart errorCode:clientErrorCode];
//                           completionHandler([NSError errorWithDomain:NEVPNErrorDomain
//                                                                 code:NEVPNErrorConnectionFailed
//                                                             userInfo:nil]);
//                         }
//                       }];
}

- (void)stopTunnelWithReason:(NEProviderStopReason)reason
           completionHandler:(void (^)(void))completionHandler {
    NSLog(@"Stopping tunnel");
    self.stopReason = reason;
    [TunnelInterface stop];
    self.svp_connectionStore.status = SVPServerConnectionStatusDisconnected;
    self.isTunnelConnected = NO;
    [self removeObserver:self forKeyPath:kDefaultPathKey];
    completionHandler();
//  [self.svp_ShadowSocks stop:^(ErrorCode errorCode) {
//    NSLog(@"Shadowsocks stopped");
//      [SVPServiceTrafficMeter stop_SVPRecordTraffic];
//    [self cancelTunnelWithError:nil];
//      [self execAppCallbackForAction:SVPActionStop errorCode:errorCode];
//    completionHandler();
//  }];
}

- (void)setupPacketTunnelFlow {
  if (self.isTunnelConnected) {
    return;
  }
  NSError *error = [TunnelInterface setupWithPacketTunnelFlow:self.packetFlow];
  if (error) {
    NSLog(@"Failed to set up tunnel packet flow: %@", error);
      [self execAppCallbackForAction:SVPActionStart errorCode:svp_vpnStartFailure];
  }
}

// Receives messages and callbacks from the app. The callback will be executed asynchronously,
// echoing the provided data on success and nil on error.
// Expects |messageData| to be JSON encoded.
- (void)handleAppMessage:(NSData *)messageData completionHandler:(void (^)(NSData *))completionHandler {
  if (messageData == nil) {
    NSLog(@"Received nil message from app");
    return;
  }
  NSDictionary *message = [NSJSONSerialization JSONObjectWithData:messageData options:kNilOptions error:nil];
  if (message == nil) {
    NSLog(@"Failed to receive message from app");
    return;
  } else if (completionHandler == nil) {
    NSLog(@"Missing message completion handler");
    return;
  }
    NSString *action = message[SVPMessageKeyAction];
  if (action == nil) {
    NSLog(@"Missing action key in app message");
    return completionHandler(nil);
  }
  NSLog(@"Received app message: %@", action);
  void (^callbackWrapper)(NSNumber *) = ^void (NSNumber *errorCode) {
    NSString *connectionId;
    if (self.svp_connection != nil) {
      connectionId = self.svp_connection.serverID;
    }
    NSDictionary *response = @{SVPMessageKeyAction: action, SVPMessageKeyErrorCode: errorCode,
                               SVPMessageKeyConnectionId: connectionId};
    completionHandler([NSJSONSerialization dataWithJSONObject:response options:kNilOptions error:nil]);
  };
  if ([SVPActionStart isEqualToString:action] || [SVPActionRestart isEqualToString:action]) {
    self.startCompletion = callbackWrapper;
    if ([SVPActionRestart isEqualToString:action]) {
        self.svp_connection = [[SVPServerConnection alloc] initWithID:message[SVPMessageKeyConnectionId] config:message[SVPMessageKeyConfig]];

      [self restartShadowsocks:true];
      [self connectTunnel:[self getTunnelNetworkSettings]
               completion:^(NSError *_Nullable error) {
                 if (error != nil) {
                   [self execAppCallbackForAction:SVPActionStart errorCode:svp_vpnStartFailure];
                   [self cancelTunnelWithError:error];
                 }
               }];
    }
  } else if ([SVPActionStop isEqualToString:action]) {
    self.stopCompletion = callbackWrapper;
  } else if ([SVPActionGetConnectionId isEqualToString:action]) {
    NSData *response = nil;
    if (self.svp_connection != nil) {
      response = [NSJSONSerialization dataWithJSONObject:@{SVPMessageKeyConnectionId: self.svp_connection.serverID}
                                                 options:kNilOptions error:nil];
    }
    completionHandler(response);
  } else if ([SVPActionIsReachable isEqualToString:action]) {
    NSString *host = message[SVPMessageKeyHost];
      NSNumber *port = message[SVPMessageKeyPort];
    if (!host || !port) {
      completionHandler(nil);
      return;
    }
    // We need to allocate an instance variable for the completion block to be retained. Otherwise,
    // the completion block gets deallocated and system sends a nil response.
//    self.svp_ShadowsConnectivity = [[ShadowsocksConnectivity alloc] initWithPort:kShadowsocksLocalPort];
    [self.svp_ShadowsConnectivity
        isReachable:[self getNetworkIpAddress:(const char *)[host UTF8String]]
               port:[port intValue]
         completion:^(BOOL isReachable) {
           ErrorCode errorCode = isReachable ? svp_noError : svp_serverUnreachable;
           NSDictionary *response = @{SVPMessageKeyErrorCode : [NSNumber numberWithLong:errorCode]};
           completionHandler(
               [NSJSONSerialization dataWithJSONObject:response options:kNilOptions error:nil]);
         }];
  }else if([SVPActionTotalDataFlow isEqualToString:action]) {
      NSDictionary *response = @{SVPMessageKeyTotalDataFlow: [NSNumber numberWithLong:[SVPServiceTrafficMeter get_SVPTotalRecordedTraffic]]};
      completionHandler(
                        [NSJSONSerialization dataWithJSONObject:response options:kNilOptions error:nil]);
  }else if([SVPActionTotalSetLimit isEqualToString:action]) {
      NSNumber *total = message[SVPMessageKeySetLimit];
      [[NSUserDefaults standardUserDefaults] setInteger:total.longValue forKey:SVPMessageKeySetLimit];
      NSLog(@"~~~~ set limit : %@", total);
      NSDictionary *response = @{@"success": [NSNumber numberWithBool:YES]};
      completionHandler(
                        [NSJSONSerialization dataWithJSONObject:response options:kNilOptions error:nil]);
  }
}

# pragma mark - Connection

// Creates a NetworkPluginConnection from options supplied in |config|, or retrieves the last working
// connection from disk. Normally the app provides a connection configuration. However, when the VPN
// is started from settings or On Demand, the system launches this process without supplying a
// configuration, so it is necessary to retrieve a previously persisted connection from disk.
// To learn more about On Demand see: https://help.apple.com/deployment/ios/#/iord4804b742.
- (SVPServerConnection *)retrieveConnection:(NSDictionary *)config {
    SVPServerConnection *connection;
    if (config != nil && !config[SVPMessageKeyOnDemand]) {
        connection = [[SVPServerConnection alloc] initWithID:config[SVPMessageKeyConnectionId] config:config];
    } else if (self.svp_connectionStore != nil) {
    NSLog(@"Retrieving connection from store.");
        connection = [self.svp_connectionStore load];
  }
  return connection;
}

# pragma mark - Network

- (void)connectTunnel:(NEPacketTunnelNetworkSettings *)settings
           completion:(void (^)(NSError *))completionHandler {
  __weak PacketTunnelProvider *weakSelf = self;
  [self setTunnelNetworkSettings:settings completionHandler:^(NSError * _Nullable error) {
    if (error != nil) {
      NSLog(@"Failed to set tunnel network settings: %@", error.localizedDescription);
    } else {
      NSLog(@"Tunnel connected");
      // Passing nil settings clears the tunnel network configuration. Indicate to the system that
      // the tunnel is being re-established if this is the case.
      weakSelf.reasserting = settings == nil;
    }
    completionHandler(error);
  }];
}

- (NEPacketTunnelNetworkSettings *)getTunnelNetworkSettings {
  NSString *vpnAddress = [self selectVpnAddress];
  NEIPv4Settings *ipv4Settings =
      [[NEIPv4Settings alloc] initWithAddresses:@[vpnAddress] subnetMasks:@[ @"255.255.255.0" ]];
  ipv4Settings.includedRoutes = @[[NEIPv4Route defaultRoute]];
  ipv4Settings.excludedRoutes = [self getExcludedIpv4Routes];

  NEIPv6Settings *ipv6Settings = [[NEIPv6Settings alloc] initWithAddresses:@[@"fd66:f83a:c650::1"]
                                                      networkPrefixLengths:@[@120]];
  ipv6Settings.includedRoutes = @[[NEIPv6Route defaultRoute]];

  // The remote address is not used for routing, but for display in Settings > VPN > NetworkPlugin.
  NEPacketTunnelNetworkSettings *settings = [[NEPacketTunnelNetworkSettings alloc] initWithTunnelRemoteAddress:self.hostNetworkAddress];
  // 不走代理的IP
  settings = [[NEPacketTunnelNetworkSettings alloc] initWithTunnelRemoteAddress:self.dnsNetworkAddress];
    
  settings.IPv4Settings = ipv4Settings;
  settings.IPv6Settings = ipv6Settings;
    
  // Configure with OpenDNS and Dyn DNS resolver addresses.
  settings.DNSSettings = [[NEDNSSettings alloc] initWithServers:@[self.dnsNetworkAddress]];
    
  return settings;
}

- (NSArray *)getExcludedIpv4Routes {
  NSMutableArray *excludedIpv4Routes = [[NSMutableArray alloc] init];
  
//    self.pingSubnetFree
    
  for (SVPServiceSubnet *subnet in [SVPServiceSubnet getSVPServerReservedSubnetsString:self.pingSubnetFree statusVip:self.pingSubnetVIP]) {
    NEIPv4Route *route =
        [[NEIPv4Route alloc] initWithDestinationAddress:subnet.svp_address subnetMask:subnet.svp_mask];
    [excludedIpv4Routes addObject:route];
  }
    
  return excludedIpv4Routes;
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath
                      ofObject:(nullable id)object
                        change:(nullable NSDictionary<NSString *, id> *)change
                       context:(nullable void *)context {
  if (![kDefaultPathKey isEqualToString:keyPath]) {
    return;
  }
  NWPath *lastPath = change[NSKeyValueChangeOldKey];
  if (lastPath == nil || [lastPath isEqualToPath:self.defaultPath] ||
      [lastPath.description isEqualToString:self.defaultPath.description]) {
    return;
  }

  dispatch_async(dispatch_get_main_queue(), ^{
    [self handleNetworkChange:self.defaultPath];
  });
}

- (void)handleNetworkChange:(NWPath *)newDefaultPath {
  NSLog(@"Network connectivity changed");
  if (newDefaultPath.status == NWPathStatusSatisfied) {
    NSLog(@"Reconnecting tunnel.");
    NSError *error = [TunnelInterface onNetworkConnectivityChange];
    if (error != nil) {
      NSLog(@"Tunnel interface failed to handle a network connectivity change: %@", error);
      return [self cancelTunnelWithError:error];
    }
    // Check whether UDP support has changed with the network.
//    ShadowsocksConnectivity *ssConnectivity =
//        [[ShadowsocksConnectivity alloc] initWithPort:kShadowsocksLocalPort];
//    [ssConnectivity isUdpForwardingEnabled:^(BOOL isUdpSupported) {
//      NSLog(@"handleNetworkChange udp %d", isUdpSupported);
//        NSLog(@"UDP support: %d -> %d", self.svp_connectionStore.isUdpSupported, isUdpSupported);
//      [TunnelInterface setIsUdpForwardingEnabled:isUdpSupported];
//        self.svp_connectionStore.isUdpSupported = isUdpSupported;
//    }];
    [self restartShadowsocks:false];
    [self connectTunnel:[self getTunnelNetworkSettings] completion:^(NSError * _Nullable error) {
      if (error != nil) {
        [self cancelTunnelWithError:error];
      }
    }];
  } else {
    NSLog(@"Clearing tunnel settings.");
    [self connectTunnel:nil completion:^(NSError * _Nullable error) {
      if (error != nil) {
        NSLog(@"Failed to clear tunnel network settings: %@", error.localizedDescription);
      } else {
        NSLog(@"Tunnel settings cleared");
      }
    }];
  }
}

bool getIpAddressString(const struct sockaddr *sa, char *s, socklen_t maxbytes) {
  if (!sa || !s) {
    NSLog(@"Failed to get IP address string: invalid argument");
    return false;
  }
  switch (sa->sa_family) {
    case AF_INET:
      inet_ntop(AF_INET, &(((struct sockaddr_in *)sa)->sin_addr), s, maxbytes);
      break;
    case AF_INET6:
      inet_ntop(AF_INET6, &(((struct sockaddr_in6 *)sa)->sin6_addr), s, maxbytes);
      break;
    default:
      NSLog(@"Cannot get IP address string: unknown address family");
      return false;
  }
  return true;
}

// Calls getaddrinfo to retrieve the IP address literal as a string for |ipv4Str| in the active network.
// This is necessary to support IPv6 DNS64/NAT64 networks. For more details see:
// https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/NetworkingOverview/UnderstandingandPreparingfortheIPv6Transition/UnderstandingandPreparingfortheIPv6Transition.html
- (NSString *)getNetworkIpAddress:(const char *)ipv4Str {
  struct addrinfo *info;
  struct addrinfo hints = {
    .ai_family = PF_UNSPEC,
    .ai_socktype = SOCK_STREAM,
    .ai_flags = AI_DEFAULT
  };
  int error = getaddrinfo(ipv4Str, NULL, &hints, &info);
  if (error) {
    NSLog(@"getaddrinfo failed: %s", gai_strerror(error));
    return NULL;
  }

  char networkAddress[INET6_ADDRSTRLEN];
  bool success = getIpAddressString(info->ai_addr, networkAddress, INET6_ADDRSTRLEN);
  freeaddrinfo(info);
  if (!success) {
    NSLog(@"inet_ntop failed with code %d", errno);
    return NULL;
  }
  return [NSString stringWithUTF8String:networkAddress];
}

- (NSArray *)getNetworkInterfaceAddresses {
  struct ifaddrs *interfaces = nil;
  NSMutableArray *addresses = [NSMutableArray new];
  if (getifaddrs(&interfaces) != 0) {
    NSLog(@"Failed to retrieve network interface addresses");
    return addresses;
  }
  struct ifaddrs *interface = interfaces;
  while (interface != nil) {
    if (interface->ifa_addr->sa_family == AF_INET) {
      // Only consider IPv4 interfaces.
      NSString *address = [NSString
          stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)interface->ifa_addr)->sin_addr)];
      [addresses addObject:address];
    }
    interface = interface->ifa_next;
  }
  freeifaddrs(interfaces);

  return addresses;
}

- (NSString *)selectVpnAddress {
  NSMutableDictionary *candidates =
    [[NSMutableDictionary alloc] initWithDictionary:kSVPSubnetCandidates];
  for (NSString *address in [self getNetworkInterfaceAddresses]) {
      for (NSString *subnetPrefix in kSVPSubnetCandidates) {
      if ([address hasPrefix:subnetPrefix]) {
        // The subnet (not necessarily the address) is in use, remove it from our list.
        [candidates removeObjectForKey:subnetPrefix];
      }
    }
  }
  if (candidates.count == 0) {
      return [self selectRandomValueFromDictionary:kSVPSubnetCandidates];
  }
  return [self selectRandomValueFromDictionary:candidates];
}

- (id)selectRandomValueFromDictionary:(NSDictionary *)dict {
  return [dict.allValues objectAtIndex:(arc4random_uniform((uint32_t)dict.count))];
}

# pragma mark - Shadowsocks

// Restarts ss-local if |configChanged| or the host's IP address has changed in the network.
- (void)restartShadowsocks:(bool)configChanged {
  if (self.hostNetworkAddress == nil || self.svp_connection == nil) {
    NSLog(@"Failed to restart Shadowsocks, missing connection configuration.");
      [self execAppCallbackForAction:SVPActionStart errorCode:svp_illegalServerConfiguration];
    return;
  }
  const char *hostAddress = (const char *)[self.svp_connection.config[@"host"] UTF8String];
  NSString *activeHostNetworkAddress = [self getNetworkIpAddress:hostAddress];
  if (!activeHostNetworkAddress) {
    NSLog(@"Failed to retrieve the remote host IP address in the network");
      [self execAppCallbackForAction:SVPActionStart errorCode:svp_illegalServerConfiguration];
    return;
  }
//  if (configChanged || ![activeHostNetworkAddress isEqualToString:self.hostNetworkAddress]) {
//    NSLog(@"Configuration or host IP address changed with the network. Restarting ss-local.");
//    self.hostNetworkAddress = activeHostNetworkAddress;
//      [self.svp_ShadowSocks stop:^(ErrorCode errorCode) {
//      NSLog(@"Shadowsocks stopped.");
//      self.svp_ShadowSocks.config = [self getShadowsocksNetworkConfig];
//      __weak PacketTunnelProvider *weakSelf = self;
//      [self.svp_ShadowSocks
//          startWithConnectivityChecks:true
//                           completion:^(ErrorCode errorCode) {
//                             ErrorCode clientErrorCode =
//          errorCode == svp_noError || errorCode == svp_udpRelayNotEnabled
//                                     ? svp_noError
//                                     : errorCode;
//                             NSLog(@"restartShadowsocks startWithConnectivityChecks Error %ld", errorCode);
//          [weakSelf execAppCallbackForAction:SVPActionStart
//                                                      errorCode:clientErrorCode];
//                             if (clientErrorCode != svp_noError) {
//                               NSLog(@"Tearing down VPN");
//                               [self cancelTunnelWithError:
//                                         [NSError errorWithDomain:NEVPNErrorDomain
//                                                             code:NEVPNErrorConnectionFailed
//                                                         userInfo:nil]];
//                               return;
//                             }
//          [weakSelf.svp_connectionStore save:self.svp_connection];
//                           }];
//    }];
//  }
}

- (NSDictionary *)getShadowsocksNetworkConfig {
  if (self.svp_connection == nil) {
    NSLog(@"Failed to retrieve configuration from nil connection");
    return nil;
  }
  NSMutableDictionary *svp_config = [[NSMutableDictionary alloc]
                                 initWithDictionary:self.svp_connection.config];
    svp_config[@"host"] = self.hostNetworkAddress;
  return svp_config;
}


# pragma mark - tun2socks

- (void)startTun2SocksWithPort:(int) port {
  if (self.isTunnelConnected) {
      [self execAppCallbackForAction:SVPActionStart errorCode:svp_noError];
    return;  // tun2socks already running
  }
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTun2SocksDone)
                                               name:kTun2SocksStoppedNotification object:nil];
  [TunnelInterface startTun2Socks:port];
  self.isTunnelConnected = YES;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
                   [TunnelInterface processPackets];
                 });
}

- (void)onTun2SocksDone {
  NSLog(@"tun2socks done");
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

# pragma mark - App IPC

// Executes a callback stored in |callbackMap| for the given |action|. |errorCode| is passed to the
// app to indicate the operation success.
// Callbacks are only executed once to prevent a bad access exception (EXC_BAD_ACCESS).
- (void)execAppCallbackForAction:(NSString *)action errorCode:(ErrorCode)code {
  NSNumber *errorCode = [NSNumber numberWithInt:code];
    if ([SVPActionStart isEqualToString:action] && self.startCompletion != nil) {
    self.startCompletion(errorCode);
    self.startCompletion = nil;
    } else if ([SVPActionStop isEqualToString:action] && self.stopCompletion != nil) {
    self.stopCompletion(errorCode);
    self.stopCompletion = nil;
  } else {
    NSLog(@"No callback for action %@", action);
  }
}

- (void)repeatCheckLimit {
    long limit = [[[NSUserDefaults standardUserDefaults] objectForKey:SVPMessageKeySetLimit] longValue];
    long total = [SVPServiceTrafficMeter get_SVPTotalRecordedTraffic];
    if (limit == -1) {
        NSLog(@"~~~~ no limit");
        return;
    }
    if (limit == 0) {
        NSLog(@"~~~ limit not set");
    }else if (limit < total) {
        NSLog(@"~~~~ beyond the limit");
        [self stopTunnelWithReason:0 completionHandler:^{
            NSLog(@"~~~~ closed");
        }];
        return;
    }
    NSLog(@"~~~ checking limit:%ld, total: %ld", limit, total);
    
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self repeatCheckLimit];
        });
    }];
}

- (void)starTrojanProxy:(NSDictionary *)options {
    NEPacketTunnelNetworkSettings * setting = [self setUpTunnelSetting];
    
    __weak typeof(self) weakSelf = self;
    [self setTunnelNetworkSettings:setting completionHandler:^(NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!error) {
            
            NSString* tunFd = [strongSelf getTunnelFD];
            NSMutableString *dns = [NSMutableString string];
            NSArray* dnsArray = [DNSConfig getSystemDnsServers];
            if (dnsArray.count > 0) {
                for (NSString* data in [DNSConfig getSystemDnsServers]) {
                    [dns appendString:[NSString stringWithFormat:@"%@,", data]];
                }
                dns = (NSMutableString*)[dns substringToIndex:dns.length - 1];
            }
            NSLog(@"dns===>%@", dns);
            
            NSArray* array = @[
                @"\n[General]",
                @"loglevel = trace",
//                @"dns-server = 114.114.114.114, 223.5.5.5",
                [NSString stringWithFormat:@"dns-server = %@", dns],
                [NSString stringWithFormat:@"tun-fd = %@", tunFd],
                @"routing-domain-resolve = true",
                @"[Proxy]",
                @"Direct = direct",
                [NSString stringWithFormat:@"Proxy = trojan, %@, %@, password=%@, mux=true", options[@"host"], options[@"port"], options[@"password"]],
                @"[Rule]",
//                @"DOMAIN-SUFFIX, 141.164.61.70, Direct",
                @"EXTERNAL, site:cn, Direct",
                @"EXTERNAL, mmdb:cn, Direct",
                @"FINAL, Proxy"
            ];
            NSLog(@"-----%@",array);
            NSMutableString *config = [NSMutableString string];
            for (NSString* data in array) {
                [config appendString:[NSString stringWithFormat:@"%@\n", data]];
            }
            
            NSLog(@"conig = %@", config);
            NSString * GroupIdentifier = [[NSString alloc] initWithFormat:@"group.%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"]];
            NSURL* url = [[NSFileManager.defaultManager containerURLForSecurityApplicationGroupIdentifier:GroupIdentifier]  URLByAppendingPathComponent:@"trojan_config.conf"];
            [config writeToURL:url atomically:NO encoding:NSUTF8StringEncoding error:nil];
            NSLog(@"url = %@", url);
        
            // The CA is used by OpenSSl.
            // You may download a CA from https://curl.se/docs/caextract.html
            NSURL* certPath = [NSBundle.mainBundle executableURL].URLByDeletingLastPathComponent;
            const char *cert_dir = [certPath.path cStringUsingEncoding:NSUTF8StringEncoding];
            setenv("SSL_CERT_DIR", cert_dir, 1);
            certPath = [certPath URLByAppendingPathComponent:@"cacert.pem"];
            const char *cert_file = [certPath.path cStringUsingEncoding:NSUTF8StringEncoding];
            setenv("SSL_CERT_FILE", cert_file, 1);
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
                signal(SIGPIPE, SIG_IGN);
                int32_t code = leaf_run_with_options(strongSelf.leaf_id, [url.path cStringUsingEncoding:NSUTF8StringEncoding], true, true, true, 2, 2048);
                NSLog(@"code = %d", code);
                dispatch_async(dispatch_get_main_queue(), ^{
                     //主线程的处理逻辑
                    [strongSelf stop];
                });
            });
            
            
        }

        if (strongSelf.completionHandler) {
            strongSelf.completionHandler(error);
        }
    }];
}

// 通道设置
- (NEPacketTunnelNetworkSettings*)setUpTunnelSetting {
//    NEPacketTunnelNetworkSettings* newSettings = [[NEPacketTunnelNetworkSettings alloc] initWithTunnelRemoteAddress:@"192.0.2.2"];
//    newSettings.IPv4Settings = [[NEIPv4Settings alloc] initWithAddresses:@[@"192.0.2.1"] subnetMasks:@[@"255.255.255.0"]];
    NEPacketTunnelNetworkSettings* newSettings = [[NEPacketTunnelNetworkSettings alloc] initWithTunnelRemoteAddress:@"240.0.0.10"];
    newSettings.IPv4Settings = [[NEIPv4Settings alloc] initWithAddresses:@[@"240.0.0.1"] subnetMasks:@[@"255.255.255.0"]];
    newSettings.IPv4Settings.includedRoutes = @[[NEIPv4Route defaultRoute]];
    newSettings.proxySettings = nil;
//    NEDNSSettings *dnsSettings = [[NEDNSSettings alloc] initWithServers:[DNSConfig getSystemDnsServers]];
    NEDNSSettings *dnsSettings = [[NEDNSSettings alloc] initWithServers:@[@"223.5.5.5", @"8.8.8.8"]];
    newSettings.DNSSettings = dnsSettings;
    newSettings.MTU = @(1500);
    return newSettings;
}

- (NSString*) getTunnelFD {
    if (@available(iOS 15.0, *)) {
        TunnelFD* fd = [TunnelFD new];
        long f = [fd getFD];
        return [NSString stringWithFormat:@"%ld", f];
    } else {
        return [self.packetFlow valueForKeyPath:@"socket.fileDescriptor"];
    }
}

- (void) stop {
    if (self.stopCompletionHandler) self.stopCompletionHandler();
    if (self.leaf_id != -1) {
        leaf_shutdown(self.leaf_id);
        self.leaf_id = -1;
        exit(0);
    }
}

@end
