//
//  SVPServiceTrafficMeter.m
//  PacketTunnel
//
//  Created by MacOSDaye on 2021/9/22.
//

#import "SVPServiceTrafficMeter.h"
#include <ifaddrs.h>
#include <net/if_dl.h>
#include <arpa/inet.h>
#include <net/if.h>


static long svp_startStatus = 0;
static long svp_trafficThisTime = 0;
static int const svp_monitorDuration = 10;
static NSString *const SVPTOTAL_TRAFFIC_KEY = @"TOTAL_TRAFFIC_KEY";

@implementation SVPServiceTrafficMeter

+ (long)getSVP_CurrentTotalTraffic {
    BOOL success;
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    const struct if_data *networkStatisc;
    long svp_WiFiSent = 0;
    long svp_WiFiReceived = 0;
    long svp_WWANSent = 0;
    long svp_WWANReceived = 0;
    NSString *name=[[NSString alloc]init];
    success = getifaddrs(&addrs) == 0;
    if (success) {
        cursor = addrs;
        while (cursor != NULL) {
            name=[NSString stringWithFormat:@"%s",cursor->ifa_name];
            
            if (cursor->ifa_addr->sa_family == AF_LINK) {

                if ([name hasPrefix:@"en"]) {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    svp_WiFiSent+=networkStatisc->ifi_obytes;
                    svp_WiFiReceived+=networkStatisc->ifi_ibytes;
                }
                
                if ([name hasPrefix:@"pdp_ip0"]) {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    svp_WWANSent+=networkStatisc->ifi_obytes;
                    svp_WWANReceived+=networkStatisc->ifi_ibytes;
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return svp_WiFiSent + svp_WiFiReceived + svp_WWANSent + svp_WWANReceived;
}

+ (void)start_SVPRecordTraffic {
    svp_startStatus = [self getSVP_CurrentTotalTraffic];
    [self repeatRecord];
}

+ (void)repeatRecord {
    if (!svp_startStatus) {
        return;
    }
    [self record];
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (svp_monitorDuration*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self repeatRecord];
        });
    }];
}

+ (void)record {
    long end = [self getSVP_CurrentTotalTraffic];
    long single = end - svp_startStatus;
    if (!svp_startStatus || !end || (end < svp_startStatus)) {
        return;
    }
    svp_startStatus = end;
    svp_trafficThisTime += single;
    long total = [[NSUserDefaults standardUserDefaults] integerForKey:SVPTOTAL_TRAFFIC_KEY];
    total += single;
    [[NSUserDefaults standardUserDefaults] setInteger:total forKey:SVPTOTAL_TRAFFIC_KEY];
}

+ (long)stop_SVPRecordTraffic {
    [self record];

    long thisTime = svp_trafficThisTime;
    svp_trafficThisTime = 0;
    svp_startStatus = 0;
    return thisTime;
}

+ (long)get_SVPTotalRecordedTraffic {
    return [[NSUserDefaults standardUserDefaults] integerForKey:SVPTOTAL_TRAFFIC_KEY];
}

+ (void)clear_SVPRecordedTraffic {
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:SVPTOTAL_TRAFFIC_KEY];
}

@end
