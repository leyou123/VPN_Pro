//
//  STDPingServices.h
//  SimplePingTest
//
//
//  
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "SVPSimplePing.h"

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, SVPPingStatus) {
    SVPPingStatusDidStart,
    SVPPingStatusDidFailToSendPacket,
    SVPPingStatusDidReceivePacket,
    SVPPingStatusDidReceiveUnexpectedPacket,
    SVPPingStatusDidTimeout,
    SVPPingStatusError,
    SVPPingStatusFinished,
};

@interface SVPPingItem : NSObject

@property(nonatomic) NSString *svp_originalAddress;
@property(nonatomic, copy) NSString *svp_IPAddress;

@property(nonatomic) NSUInteger dateBytesLength;
@property(nonatomic) double     timeMilliseconds;
@property(nonatomic) NSInteger  timeToLive;
@property(nonatomic) NSInteger  ICMPSequence;

@property(nonatomic) SVPPingStatus svp_status;

+ (NSString *)svp_statisticsWithPingItems:(NSArray *)pingItems;

@end

@interface SVPPingServices : NSObject

@property(nonatomic) double svp_timeoutMilliseconds;//default 500ms

+ (SVPPingServices *)svp_startPingAddress:(NSString *)address
                      callbackHandler:(void(^)(SVPPingItem *pingItem, NSArray *pingItems))handler;

@property(nonatomic) NSInteger  maximumPingTimes;

- (void)cancel;

@end


NS_ASSUME_NONNULL_END
