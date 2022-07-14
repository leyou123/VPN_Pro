#ifndef ShadowsocksConnectivity_h
#define ShadowsocksConnectivity_h

#import <Foundation/Foundation.h>
#import "PacketTunnelProvider.h"

@interface ShadowsocksConnectivity : NSObject

- (id)initWithPort:(uint16_t)shadowsocksPort;

- (void)isUdpForwardingEnabled:(void (^)(BOOL))completion;

- (void)checkServerCredentials:(void (^)(BOOL))completion;

- (void)isReachable:(NSString *)host port:(uint16_t)port completion:(void (^)(BOOL))completion;

@end

#endif /* ShadowsocksConnectivity_h */
