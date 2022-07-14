//
//  SVPServerConnectivity.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/15.
//

#import "SVPServerConnectivity.h"
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <err.h>

@interface SVPServerConnectivity()
@property (assign, nonatomic) double kSocketTimeoutSecs;
@property (strong, nonatomic) NSMutableDictionary  *reachabilityCallbackBySocket;
@property (strong, nonatomic) dispatch_queue_t delegateQueue;

@end

@implementation SVPServerConnectivity

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.kSocketTimeoutSecs = 10.0;
        self.reachabilityCallbackBySocket = [NSMutableDictionary dictionary];
        self.delegateQueue = dispatch_queue_create("tcp", NULL);
    }
    return self;
}

- (BOOL)isServerReachable:(NSString *)host port:(uint16_t)port completion:(void(^)(BOOL))completion {
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.delegateQueue];
        NSError *error;
        [socket connectToHost:host onPort:port error:&error];
        if (error) {
            completion(NO);
        }else {
            NSString *key = [NSString stringWithFormat:@"%p", socket];
            self.reachabilityCallbackBySocket[key] = completion;
        }
    }];
    return YES;
}

//代理 方法
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    [self sendSocketReachability:sock reachable:YES];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    [self sendSocketReachability:sock reachable:NO];
}

- (void)sendSocketReachability:(GCDAsyncSocket *)sock reachable:(BOOL)reachable {
    if (sock) {
        NSString *key = [NSString stringWithFormat:@"%p", sock];
        void(^callBack)(BOOL) = self.reachabilityCallbackBySocket[key];
        callBack(reachable);
        self.reachabilityCallbackBySocket[key] = nil;
    }
}

@end
