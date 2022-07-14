//
//  SVPServerConnectionStore.m
//  PacketTunnel
//
//  Created by MacOSDaye on 2021/9/22.
//

#import "SVPServerConnectionStore.h"

static NSString *const svp_ConnectionStoreKey = @"connectionStore";
static NSString *const svp_ConnectionStatusKey = @"connectionStatus";
static NSString *const svp_UdpSupportKey = @"udpSupport";

@interface SVPServerConnectionStore()
@property (strong, nonatomic) NSUserDefaults *defaults;
@property (strong, nonatomic) NSString *svp_ConnectionStoreKey;
@property (strong, nonatomic) NSString *svp_ConnectionStatusKey;
@property (strong, nonatomic) NSString *svp_UdpSupportKey;
@end

@implementation SVPServerConnectionStore

- (instancetype)initWithAppGroup:(NSString *)appGroupName {
    self = [super init];
    if (self) {
        self.defaults = [[NSUserDefaults alloc] initWithSuiteName:appGroupName];
        self.svp_ConnectionStoreKey = @"connectionStore";
        self.svp_ConnectionStatusKey = @"connectionStatus";
        self.svp_UdpSupportKey = @"udpSupport";
    }
    return self;
}

- (SVPServerConnectionStatus)status {
    return [self.defaults integerForKey:self.svp_ConnectionStatusKey] || SVPServerConnectionStatusDisconnected;
}

- (void)setStatus:(SVPServerConnectionStatus)status {
    [self.defaults setInteger:status forKey:self.svp_ConnectionStatusKey];
    [self.defaults synchronize];
}

- (BOOL)isUdpSupported {
    return [self.defaults boolForKey:self.svp_UdpSupportKey] || NO;
}

- (void)setIsUdpSupported:(BOOL)isUdpSupported {
    [self.defaults setBool:isUdpSupported forKey:self.svp_UdpSupportKey];
}

- (BOOL)save:(SVPServerConnection *)connection {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:connection];
    [self.defaults setObject:data forKey:self.svp_ConnectionStoreKey];
    return YES;
}

- (SVPServerConnection *)load {
    NSData *data = [self.defaults objectForKey:self.svp_ConnectionStoreKey];
    NSError *err;
    SVPServerConnection *connection = [NSKeyedUnarchiver unarchiveTopLevelObjectWithData:data error:&err];
    if (err) {
        NSLog(@"%@",err);
        return nil;
    }else {
        return connection;
    }
}

@end
