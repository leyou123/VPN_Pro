//
//  SVPSeverInfo.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/13.
//

#import "SVPSeverInfo.h"

@implementation SVPSeverInfo

+ (instancetype)setupSVPInfoWithData:(id)svp_data {
    
    SVPSeverInfo *svp_vpnInfo = [[SVPSeverInfo alloc] init];
    if ([svp_data isKindOfClass:[NSDictionary class]]) {
        svp_data[@"serverAddress"] ? svp_vpnInfo.svp_serverAddress = svp_data[@"serverAddress"] : 0;
        svp_data[@"remoteID"] ? svp_vpnInfo.svp_remoteID = svp_data[@"remoteID"] : 0;
        svp_data[@"username"] ? svp_vpnInfo.svp_username = svp_data[@"username"] : 0;
        svp_data[@"password"] ? svp_vpnInfo.svp_password = svp_data[@"password"] : 0;
        svp_data[@"sharedSecret"] ? svp_vpnInfo.svp_sharedSecret = svp_data[@"sharedSecret"] : 0;
        svp_data[@"preferenceTitle"] ? svp_vpnInfo.svp_preferenceTitle = svp_data[@"preferenceTitle"] : 0;
    } else if ([svp_data isKindOfClass:[self class]]) {
        svp_vpnInfo = svp_data;
    }
    return svp_vpnInfo;
}

@end
