//
//  GBPingTool.m
//  Ping
//
//  Created by one on 2019/12/18.
//  Copyright © 2019 one. All rights reserved.
//

#import "GBPingTool.h"

static GBPingTool *shared = nil;

@interface GBPingTool()<GBPingDelegate>
@property (strong, nonatomic) GBPing *ping;
//@property (assign, nonatomic) NSUInteger times;
@property (strong, nonatomic) ResultCallback callback;
@end

@implementation GBPingTool

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [super allocWithZone:zone];
    });
    
    return shared;
}

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (void)ping:(NSString *)host result: (ResultCallback)callBack {
    self.ping = [[GBPing alloc] init];
    self.ping.host = host;
    self.ping.delegate = self;
    self.ping.timeout = 1.0;
    self.ping.pingPeriod = 0.9;
    self.callback = callBack;
    [self.ping setupWithBlock:^(BOOL success, NSError *error) {
        if (success) {
            [self.ping startPinging];
        }
    }];
}


-(void)ping:(GBPing *)pinger didReceiveReplyWithSummary:(GBPingSummary *)summary {
    [self handleResult:YES :summary];
}

-(void)ping:(GBPing *)pinger didTimeoutWithSummary:(GBPingSummary *)summary {
    [self handleResult:NO :summary];
}

- (void)handleResult:(BOOL)success :(GBPingSummary *)summary {
    if (self.callback) {
        self.callback(success, summary);
    }
    self.callback = nil;
}
@end
