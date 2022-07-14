//
//  SVPServerConnection.h
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    SVPServerConnectionStatusConnected,
    SVPServerConnectionStatusDisconnected,
    SVPServerConnectionStatusReconnecting,
} SVPServerConnectionStatus;
@interface SVPServerConnection : NSObject<NSCoding>
@property (strong, nonatomic) NSString *serverID;
@property (strong, nonatomic) NSString *host;
@property (strong, nonatomic) NSString *port;
@property (strong, nonatomic) NSString *method;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *dns;
@property (strong, nonatomic) NSString *pingSubnetFree;
@property (strong, nonatomic) NSString *pingSubnetVIP;
@property (strong, nonatomic) NSDictionary *config;
- (instancetype)initWithID:(NSString *)serverID config:(NSDictionary *)config;
@end

NS_ASSUME_NONNULL_END
