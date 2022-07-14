//
//  STNetMeasure.m
//  STNetMeasure
//
//  Created by one on 2020/2/4.
//  Copyright © 2020 one. All rights reserved.
//
@import UIKit;
#import "STNetMeasure.h"
#import "GBPingTool.h"

static UIBackgroundTaskIdentifier backgroundTaskID = 0;

@implementation STNetMeasure

+ (void)measureForDelay:(NSString *)ip bandwidth:(NSString *)file finish:(NetMeasureFinish)finish {
    if (backgroundTaskID != UIBackgroundTaskInvalid) {
        finish(NO, nil);
        return;
    }
    [self startBackgroundTask];
    [self dalayMeasure:ip finish:^(BOOL success, NSDictionary *delayResult) {
        if (!success && finish) {
            finish(NO, nil);
            return;
        }
        [self bandwidthMeasure:file finish:^(BOOL success, NSDictionary *bandwidthResult) {
            if (!success && finish) {
                finish(NO, nil);
                return;
            }
        
            NSDictionary *result = @{
                                     kDelayResultKey: delayResult,
                                     kBandwidthResultKey: bandwidthResult,
                                     };
            if (finish) {
                finish(YES, result);
            }
        }];
    }];
    
}

+ (void)startBackgroundTask {
    backgroundTaskID = [UIApplication.sharedApplication beginBackgroundTaskWithExpirationHandler:^{
        [UIApplication.sharedApplication endBackgroundTask:backgroundTaskID];
        backgroundTaskID = UIBackgroundTaskInvalid;
    }];
}

+ (void)bandwidthMeasure:(NSString *)file finish:(NetMeasureFinish)finish {
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        NSDate *start = [NSDate date];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:file]];
        NSDate *end = [NSDate date];
        NSNumber *interval = [NSNumber numberWithFloat:[end timeIntervalSinceDate:start]];
        NSNumber *dataLenth = [NSNumber numberWithUnsignedInteger:data.length];
        
        NSDictionary *result = @{
                                 kBandwidthFileKey: file,
                                 kStartTimeKey: start,
                                 kFinishTimeKey: end,
                                 kIntervalKey: interval,
                                 kDataLengthKey: dataLenth,
                                 };
        if (finish) {
            finish(YES, result);
        }
    }];
    
}

+ (void)dalayMeasure:(NSString *)ip finish:(NetMeasureFinish)finish{
    [GBPingTool.shared ping:ip result:^(BOOL success, GBPingSummary * _Nonnull summary) {
        id receiveDate = summary.receiveDate ? summary.receiveDate : @"";
        NSDictionary *result = @{
                   kPingHostKey: ip,
                   kPingIPKey: summary.host,
                   kStartTimeKey: summary.sendDate,
                   kFinishTimeKey: receiveDate,
                   kDelayKey: [NSNumber numberWithFloat:summary.rtt],
                   };
        
        if (finish) {
            finish(success, result);
        }
    }];
    
}
@end
