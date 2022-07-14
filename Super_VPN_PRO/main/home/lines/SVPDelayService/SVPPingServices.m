//
//  STDPingServices.m
//  SimplePingTest
//
//
//
//

#import "SVPPingServices.h"

@implementation SVPPingItem

- (NSString *)description {
    switch (self.svp_status) {
        case SVPPingStatusDidStart:
            return [NSString stringWithFormat:@"PING %@ (%@): %ld data bytes",self.svp_originalAddress, self.svp_IPAddress, (long)self.dateBytesLength];
        case SVPPingStatusDidReceivePacket:
            return [NSString stringWithFormat:@"%ld bytes from %@: icmp_seq=%ld ttl=%ld time=%.3f ms", (long)self.dateBytesLength, self.svp_IPAddress, (long)self.ICMPSequence, (long)self.timeToLive, self.timeMilliseconds];
        case SVPPingStatusDidTimeout:
            return [NSString stringWithFormat:@"Request timeout for icmp_seq %ld", (long)self.ICMPSequence];
        case SVPPingStatusDidFailToSendPacket:
            return [NSString stringWithFormat:@"Fail to send packet to %@: icmp_seq=%ld", self.svp_IPAddress, (long)self.ICMPSequence];
        case SVPPingStatusDidReceiveUnexpectedPacket:
            return [NSString stringWithFormat:@"Receive unexpected packet from %@: icmp_seq=%ld", self.svp_IPAddress, (long)self.ICMPSequence];
        case SVPPingStatusError:
            return [NSString stringWithFormat:@"Can not ping to %@", self.svp_originalAddress];
        default:
            break;
    }
    if (self.svp_status == SVPPingStatusDidReceivePacket) {
    }
    return super.description;
}

+ (NSString *)svp_statisticsWithPingItems:(NSArray *)pingItems {
    NSString *svp_address = [pingItems.firstObject svp_originalAddress];
    __block NSInteger svp_receivedCount = 0, svp_allCount = 0;
    [pingItems enumerateObjectsUsingBlock:^(SVPPingItem *obj, NSUInteger idx, BOOL *stop) {
        if (obj.svp_status != SVPPingStatusFinished && obj.svp_status != SVPPingStatusError) {
            svp_allCount ++;
            if (obj.svp_status == SVPPingStatusDidReceivePacket) {
                svp_receivedCount ++;
            }
        }
    }];
    
    NSMutableString *svp_description = [NSMutableString stringWithCapacity:50];
    [svp_description appendFormat:@"--- %@ ping statistics ---\n", svp_address];
    
    CGFloat svp_lossPercent = (CGFloat)(svp_allCount - svp_receivedCount) / MAX(1.0, svp_allCount) * 100;
    [svp_description appendFormat:@"%ld packets transmitted, %ld packets received, %.1f%% packet loss\n", (long)svp_allCount, (long)svp_receivedCount, svp_lossPercent];
    return [svp_description stringByReplacingOccurrencesOfString:@".0%" withString:@"%"];
}
@end

@interface SVPPingServices () <SVPSimplePingDelegate> {
    BOOL _hasStarted;
    BOOL _isTimeout;
    NSInteger   _repingTimes;
    NSInteger   _sequenceNumber;
    NSMutableArray *_pingItems;
}

@property(nonatomic, copy)   NSString   *svp_address;
@property(nonatomic, strong) SVPSimplePing *svp_simplePing;

@property(nonatomic, strong)void(^callbackHandler)(SVPPingItem *item, NSArray *pingItems);

@end

@implementation SVPPingServices

+ (SVPPingServices *)svp_startPingAddress:(NSString *)address
                      callbackHandler:(void(^)(SVPPingItem *item, NSArray *pingItems))handler {
    SVPPingServices *svp_services = [[SVPPingServices alloc] initWithAddress:address];
    svp_services.callbackHandler = handler;
    [svp_services startPing];
    return svp_services;
}

- (instancetype)initWithAddress:(NSString *)address {
    self = [super init];
    if (self) {
        self.svp_timeoutMilliseconds = 500;
        self.maximumPingTimes = 3;
        self.svp_address = address;
        self.svp_simplePing = [[SVPSimplePing alloc] initWithSVPHostName:address];
        self.svp_simplePing.addressStyle = SVPSimplePingAddressStyleAny;
        self.svp_simplePing.delegate = self;
        _pingItems = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

- (void)startPing {
    _repingTimes = 0;
    _hasStarted = NO;
    [_pingItems removeAllObjects];
    [self.svp_simplePing start];
}

- (void)reping {
    [self.svp_simplePing stop];
    [self.svp_simplePing start];
}

- (void)_timeoutActionFired {
    SVPPingItem *svp_pingItem = [[SVPPingItem alloc] init];
    svp_pingItem.ICMPSequence = _sequenceNumber;
    svp_pingItem.svp_originalAddress = self.svp_address;
    svp_pingItem.svp_status = SVPPingStatusDidTimeout;
    [self.svp_simplePing stop];
    [self svp_handlePingItem:svp_pingItem];
}

- (void)svp_handlePingItem:(SVPPingItem *)pingItem {
    if (pingItem.svp_status == SVPPingStatusDidReceivePacket || pingItem.svp_status == SVPPingStatusDidTimeout) {
        [_pingItems addObject:pingItem];
    }
    if (_repingTimes < self.maximumPingTimes - 1) {
        if (self.callbackHandler) {
            self.callbackHandler(pingItem, [_pingItems copy]);
        }
        _repingTimes ++;//注释掉，无限ping
        NSTimer *timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(reping) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    } else {
        if (self.callbackHandler) {
            self.callbackHandler(pingItem, [_pingItems copy]);
        }
        [self cancel];
    }
}

- (void)cancel {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(_timeoutActionFired) object:nil];
    [self.svp_simplePing stop];
    self.svp_simplePing.delegate = nil;//清除代理
    SVPPingItem *svp_pingItem = [[SVPPingItem alloc] init];
    svp_pingItem.svp_status = SVPPingStatusFinished;
    [_pingItems addObject:svp_pingItem];
    if (self.callbackHandler) {
        self.callbackHandler(svp_pingItem, [_pingItems copy]);
    }
}

- (void)svp_simplePing:(SVPSimplePing *)pinger didStartWithAddress:(NSData *)address {
    NSData *packet = [pinger packetWithPingData:nil];
    if (!_hasStarted) {
        SVPPingItem *svp_pingItem = [[SVPPingItem alloc] init];
        svp_pingItem.svp_IPAddress = pinger.IPAddress;
        svp_pingItem.svp_originalAddress = self.svp_address;
        svp_pingItem.dateBytesLength = packet.length - sizeof(SVPICMPHeader);
        svp_pingItem.svp_status = SVPPingStatusDidStart;
        if (self.callbackHandler) {
            self.callbackHandler(svp_pingItem, nil);
        }
        _hasStarted = YES;
    }
    [pinger sendPacket:packet];
    [self performSelector:@selector(_timeoutActionFired) withObject:nil afterDelay:self.svp_timeoutMilliseconds / 1000.0];
}

- (void)svp_simplePing:(SVPSimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber {
    _sequenceNumber = sequenceNumber;
}

- (void)svp_simplePing:(SVPSimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(_timeoutActionFired) object:nil];
    _sequenceNumber = sequenceNumber;
    SVPPingItem *svp_pingItem = [[SVPPingItem alloc] init];
    svp_pingItem.ICMPSequence = _sequenceNumber;
    svp_pingItem.svp_originalAddress = self.svp_address;
    svp_pingItem.svp_status = SVPPingStatusDidFailToSendPacket;
    [self svp_handlePingItem:svp_pingItem];
}

- (void)svp_simplePing:(SVPSimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(_timeoutActionFired) object:nil];
    SVPPingItem *svp_pingItem = [[SVPPingItem alloc] init];
    svp_pingItem.ICMPSequence = _sequenceNumber;
    svp_pingItem.svp_originalAddress = self.svp_address;
    svp_pingItem.svp_status = SVPPingStatusDidReceiveUnexpectedPacket;
    //    [self _handlePingItem:pingItem];
}

- (void)svp_simplePing:(SVPSimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet timeToLive:(NSInteger)timeToLive sequenceNumber:(uint16_t)sequenceNumber timeElapsed:(NSTimeInterval)timeElapsed {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(_timeoutActionFired) object:nil];
    SVPPingItem *svp_pingItem = [[SVPPingItem alloc] init];
    svp_pingItem.svp_IPAddress = pinger.IPAddress;
    svp_pingItem.dateBytesLength = packet.length;
    svp_pingItem.timeToLive = timeToLive;
    svp_pingItem.timeMilliseconds = timeElapsed * 1000;
    svp_pingItem.ICMPSequence = sequenceNumber;
    svp_pingItem.svp_originalAddress = self.svp_address;
    svp_pingItem.svp_status = SVPPingStatusDidReceivePacket;
    [self svp_handlePingItem:svp_pingItem];
}

- (void)svp_simplePing:(SVPSimplePing *)pinger didFailWithError:(NSError *)error {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(_timeoutActionFired) object:nil];
    [self.svp_simplePing stop];
    
    SVPPingItem *errorPingItem = [[SVPPingItem alloc] init];
    errorPingItem.svp_originalAddress = self.svp_address;
    errorPingItem.svp_status = SVPPingStatusError;
    if (self.callbackHandler) {
        self.callbackHandler(errorPingItem, [_pingItems copy]);
    }
    
    SVPPingItem *svp_pingItem = [[SVPPingItem alloc] init];
    svp_pingItem.svp_originalAddress = self.svp_address;
    svp_pingItem.svp_IPAddress = pinger.IPAddress ?: pinger.hostName;
    [_pingItems addObject:svp_pingItem];
    svp_pingItem.svp_status = SVPPingStatusFinished;
    if (self.callbackHandler) {
        self.callbackHandler(svp_pingItem, [_pingItems copy]);
    }
}

@end
