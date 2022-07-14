//
//  SVPServiceTrafficMeter.h
//  PacketTunnel
//
//  Created by MacOSDaye on 2021/9/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SVPServiceTrafficMeter : NSObject
+ (void)start_SVPRecordTraffic;
+ (long)stop_SVPRecordTraffic;
+ (long)get_SVPTotalRecordedTraffic;
+ (void)clear_SVPRecordedTraffic;
@end

NS_ASSUME_NONNULL_END
