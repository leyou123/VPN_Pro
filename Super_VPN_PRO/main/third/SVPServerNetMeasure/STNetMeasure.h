//
//  STNetMeasure.h
//  STNetMeasure
//
//  Created by one on 2020/2/4.
//  Copyright © 2020 one. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^NetMeasureFinish)(BOOL success, NSDictionary *result);

static NSString *const kErrorKey = @"error";
static NSString *const kDelayResultKey = @"ping";
static NSString *const kBandwidthResultKey = @"bandwidth";

static NSString *const kStartTimeKey = @"start-time";
static NSString *const kFinishTimeKey = @"finish-time";
static NSString *const kDataLengthKey = @"data-length";
static NSString *const kBandwidthFileKey = @"bandwidth-file";
static NSString *const kIntervalKey = @"time-interval";

static NSString *const kPingHostKey = @"ping-host";
static NSString *const kPingIPKey = @"ping-ip";
static NSString *const kDelayKey = @"ping-delay";

@interface STNetMeasure : NSObject
+ (void)measureForDelay:(NSString *)ip bandwidth:(NSString *)file finish:(NetMeasureFinish)finish;
@end

