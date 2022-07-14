//
//  SVPServiceSubnet.m
//  PacketTunnel
//
//  Created by MacOSDaye on 2021/9/22.
//

#import "SVPServiceSubnet.h"

@implementation SVPServiceSubnet

- (instancetype)initWithAddress:(NSString *)addressSVP_ServerString prefix:(uint16_t)prefixSVPServer {
    self = [super init];
    if (self) {
        self.svp_address = addressSVP_ServerString;
        self.svp_prefix = prefixSVPServer;
        uint32_t mask = (uint32_t)(0xffffffff) << (32 - prefixSVPServer);
        uint8_t a = (uint8_t)((mask >> 24) & 0xff);
        uint8_t b = (uint8_t)((mask >> 16) & 0xff);
        uint8_t c = (uint8_t)((mask >> 8) & 0xff);
        uint8_t d = (uint8_t)((mask) & 0xff);
        self.svp_mask = [NSString stringWithFormat:@"%d.%d.%d.%d",a,b,c,d];
    }
    return self;
}

+ (SVPServiceSubnet *)parse:(NSString *)cidrSubnet {
    NSArray *components = [cidrSubnet componentsSeparatedByString:@"/"];
    if (components.count != 2) {
        return nil;
    }
    uint16_t prefix = [components[1] intValue];
    if (prefix > 0) {
        return [[SVPServiceSubnet alloc] initWithAddress:components[0] prefix:prefix];
    }else {
        return nil;
    }
}

+ (NSArray<SVPServiceSubnet *> *)getReservedSubnets {
    NSArray *kReservedSubnets = @[
      @"10.0.0.0/8",
      @"100.64.0.0/10",
      @"169.254.0.0/16",
      @"172.16.0.0/12",
      @"192.0.0.0/24",
      @"192.0.2.0/24",
      @"192.31.196.0/24",
      @"192.52.193.0/24",
      @"192.88.99.0/24",
      @"192.168.0.0/16",
      @"192.175.48.0/24",
      @"198.18.0.0/15",
      @"198.51.100.0/24",
      @"203.0.113.0/24",
      @"240.0.0.0/4"
    ];
    NSMutableArray *svp_ServerSubnetsArray = [NSMutableArray array];
    for (NSString *cidrSubnet in kReservedSubnets) {
        SVPServiceSubnet *subnetSer = [self parse:cidrSubnet];
        if (subnetSer) {
            [svp_ServerSubnetsArray addObject:subnetSer];
        }
    }
    return svp_ServerSubnetsArray;
}

+ (NSArray<SVPServiceSubnet *> *)getSVPServerReservedSubnetsString:(NSString *)svp_ServerFreeStatus statusVip:(NSString *)svp_ServerVipStatus{
   
    NSArray *svp_ServerFreeArray = [svp_ServerFreeStatus componentsSeparatedByString:@","];
    NSArray *svp_ServerVipArray =  [svp_ServerVipStatus componentsSeparatedByString:@","];
    NSArray *svp_ReservedSubnets = @[
                                  @"10.0.0.0/8",
                                  @"100.64.0.0/10",
                                  @"169.254.0.0/16",
                                  @"172.16.0.0/12",
                                  @"192.0.0.0/24",
                                  @"192.0.2.0/24",
                                  @"192.31.196.0/24",
                                  @"192.52.193.0/24",
                                  @"192.88.99.0/24",
                                  @"192.168.0.0/16",
                                  @"192.175.48.0/24",
                                  @"198.18.0.0/15",
                                  @"198.51.100.0/24",
                                  @"203.0.113.0/24",
                                  @"240.0.0.0/4",
                                  ];
    
    NSMutableArray *svp_TotalArray = [NSMutableArray array];
    [svp_TotalArray addObjectsFromArray:[self svp_handleArray:svp_ReservedSubnets]];
    [svp_TotalArray addObjectsFromArray:[self svp_handleArray:svp_ServerFreeArray]];
    [svp_TotalArray addObjectsFromArray:[self svp_handleArray:svp_ServerVipArray]];

    NSMutableArray *svp_SubnetsArray = [NSMutableArray array];
    for (NSString *cidrSubnet in svp_TotalArray) {
        SVPServiceSubnet *svp_Subnet = [self parse:cidrSubnet];
        if (svp_Subnet) {
            [svp_SubnetsArray addObject:svp_Subnet];
        }
    }
    return svp_SubnetsArray;
}

+ (NSArray *)svp_handleArray:(NSArray *)origin {
    NSMutableArray * retArray = [NSMutableArray array];
    for (NSString *str in origin) {
        if (str.length != 0) {
            [retArray addObject:str];
        }
    }
    return retArray;
}
@end
