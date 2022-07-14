//
//  SVPServerConnection.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/15.
//

#import "SVPServerConnection.h"

@implementation SVPServerConnection
- (instancetype)initWithID:(NSString *)serverID config: (NSDictionary *)config {
    self = [super init];
    if (self) {
        self.serverID = serverID;
        self.host = config[@"host"];
        self.password = config[@"password"];
        self.method = config[@"method"];
        self.dns = config[@"dns"];
        if (config[@"pingSubnetFree"] != nil){
            self.pingSubnetFree = config[@"pingSubnetFree"];
        }else{
            self.pingSubnetFree = @"";
        }
        if (config[@"pingSubnetVIP"] != nil){
            self.pingSubnetVIP = config[@"pingSubnetVIP"];
        }else{
            self.pingSubnetVIP = @"";
        }
        
        NSString *port = config[@"port"];
        if (port) {
            self.port = port;
        }
    }
    return self;
}

- (NSDictionary *)config {
    return @{
        @"host": self.host,
        @"port": self.port,
        @"password": self.password,
        @"method": self.method,
        @"dns": self.dns,
        @"pingSubnetFree": self.pingSubnetFree,
        @"pingSubnetVIP": self.pingSubnetVIP,
    };
}
- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:self.serverID forKey:@"id"];
    [coder encodeObject:self.host forKey:@"host"];
    [coder encodeObject:self.password forKey:@"password"];
    [coder encodeObject:self.method forKey:@"method"];
    [coder encodeObject:self.dns forKey:@"dns"];
    [coder encodeObject:self.port forKey:@"port"];
    [coder encodeObject:self.pingSubnetFree forKey:@"pingSubnetFree"];
    [coder encodeObject:self.pingSubnetVIP forKey:@"pingSubnetVIP"];

}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]) {
        self.serverID = [coder decodeObjectForKey:@"id"];
        self.host = [coder decodeObjectForKey:@"host"];
        self.password = [coder decodeObjectForKey:@"password"];
        self.method = [coder decodeObjectForKey:@"method"];
        self.dns = [coder decodeObjectForKey:@"dns"];
        self.port = [coder decodeObjectForKey:@"port"];
        self.pingSubnetFree = [coder decodeObjectForKey:@"pingSubnetFree"];
        self.pingSubnetVIP = [coder decodeObjectForKey:@"pingSubnetVIP"];
    }
    return self;
}
@end
