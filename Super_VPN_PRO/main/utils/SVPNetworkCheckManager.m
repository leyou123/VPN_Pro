//
//  SVPNetworkCheckManager.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/9.
//

#import "SVPNetworkCheckManager.h"
#import <SystemConfiguration/SystemConfiguration.h>

@implementation SVPNetworkCheckManager

+ (BOOL)checkSVPNetworkConnection{
    struct sockaddr zeroAddress;
    bzero(&zeroAddress,sizeof(zeroAddress));
    zeroAddress.sa_len=sizeof(zeroAddress);
    zeroAddress.sa_family=AF_INET;
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didReceiveFlags =SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    if(!didReceiveFlags) {
        return NO;
    }
    BOOL isReachable = flags &kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    BOOL flag =(isReachable && !needsConnection) ?YES:NO;
    return flag;
}
@end
