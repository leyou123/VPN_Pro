//
//  SVPServiceSubnet.h
//  PacketTunnel
//
//  Created by MacOSDaye on 2021/9/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SVPServiceSubnet : NSObject

@property(strong, nonatomic)NSString *svp_address;
@property(assign, nonatomic)uint16_t svp_prefix;
@property(strong, nonatomic)NSString *svp_mask;

+ (NSArray<SVPServiceSubnet *> *)getReservedSubnets;

+ (NSArray<SVPServiceSubnet *> *)getSVPServerReservedSubnetsString:(NSString *)svp_ServerFreeStatus statusVip:(NSString *)svp_ServerVipStatus;
@end

NS_ASSUME_NONNULL_END
