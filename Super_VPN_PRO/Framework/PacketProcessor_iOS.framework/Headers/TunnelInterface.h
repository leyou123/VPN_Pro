#import <Foundation/Foundation.h>

@import NetworkExtension;

#define TunnelMTU 1600
#define kTun2SocksStoppedNotification @"kTun2SocksStoppedNotification"

@interface TunnelInterface : NSObject
+ (TunnelInterface *)sharedInterface;
+ (NSError *)setupWithPacketTunnelFlow:(NEPacketTunnelFlow *)packetFlow;
+ (NSError *)onNetworkConnectivityChange;
+ (void)processPackets;
+ (void)writePacket: (NSData *)packet;
+ (void)startTun2Socks: (int)socksServerPort;
+ (void)stop;
+ (void)setIsUdpForwardingEnabled:(BOOL)enabled;
@end
