//
//  SVPSimplePing.h
//  SimplePingTest
//
//
//  
//

#import <Foundation/Foundation.h>
#include <AssertMacros.h>           // for __Check_Compile_Time

NS_ASSUME_NONNULL_BEGIN

@protocol SVPSimplePingDelegate;

/*! Controls the IP address version used by SimplePing instances.
 */
typedef NS_ENUM(NSInteger, SVPSimplePingAddressStyle) {
    SVPSimplePingAddressStyleAny,          ///< Use the first IPv4 or IPv6 address found; the default.
    SVPSimplePingAddressStyleICMPv4,       ///< Use the first IPv4 address found.
    SVPSimplePingAddressStyleICMPv6        ///< Use the first IPv6 address found.
};

@interface SVPSimplePing : NSObject


- (instancetype)init NS_UNAVAILABLE;

/*! Initialise the object to ping the specified host.
 *  \param hostName The DNS name of the host to ping; an IPv4 or IPv6 address in string form will
 *      work here.
 *  \returns The initialised object.
 */
- (instancetype)initWithSVPHostName:(NSString *)hostName NS_DESIGNATED_INITIALIZER;

/*! A copy of the value passed to `-initWithSVPHostName:`.
 */
@property (nonatomic, copy, readonly) NSString * hostName;

/*! The delegate for this object.
 *  \details Delegate callbacks are schedule in the default run loop mode of the run loop of the
 *      thread that calls `-start`.
 */
@property (nonatomic, weak, readwrite, nullable) id<SVPSimplePingDelegate> delegate;

/*! Controls the IP address version used by the object.
 *  \details You should set this value before starting the object.
 */
@property (nonatomic, assign, readwrite) SVPSimplePingAddressStyle addressStyle;

@property (nonatomic, copy, readonly, nullable) NSData * hostAddress;
@property (nonatomic, copy, readonly, nullable) NSString *IPAddress;
@property (nonatomic, assign, readonly) NSInteger packetLength;

/*! The address family for `hostAddress`, or `AF_UNSPEC` if that's nil.
 */
@property (nonatomic, assign, readonly) sa_family_t hostAddressFamily;

@property (nonatomic, assign, readonly) uint16_t identifier;

@property (nonatomic, assign, readonly) uint16_t nextSequenceNumber;

- (void)start;

- (nonnull NSData *)packetWithPingData:(nullable  NSData *)data;

- (void)sendPacket:(nonnull NSData *)data;

/*! Stops the object.
 *  \details You should call this when you're done pinging.
 *
 *      It's safe to call this on an object that's stopped.
 */
- (void)stop;


@end

@protocol SVPSimplePingDelegate <NSObject>

@optional

- (void)svp_simplePing:(SVPSimplePing *)pinger didStartWithAddress:(NSData *)address;

- (void)svp_simplePing:(SVPSimplePing *)pinger didFailWithError:(NSError *)error;

- (void)svp_simplePing:(SVPSimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber;

- (void)svp_simplePing:(SVPSimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error;

- (void)svp_simplePing:(SVPSimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet timeToLive:(NSInteger)timeToLive sequenceNumber:(uint16_t)sequenceNumber timeElapsed:(NSTimeInterval)timeElapsed;

- (void)svp_simplePing:(SVPSimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet;

@end

#pragma mark * ICMP On-The-Wire Format
/*! Describes the on-the-wire header format for an ICMP ping.
 *  \details This defines the header structure of ping packets on the wire.  Both IPv4 and
 *      IPv6 use the same basic structure.
 *
 *      This is declared in the header because clients of SimplePing might want to use
 *      it parse received ping packets.
 */

struct SVPICMPHeader {
    uint8_t     type;
    uint8_t     code;
    uint16_t    checksum;
    uint16_t    identifier;
    uint16_t    sequenceNumber;
    // data...
};

typedef struct SVPICMPHeader SVPICMPHeader;

__Check_Compile_Time(sizeof(SVPICMPHeader) == 8);
__Check_Compile_Time(offsetof(SVPICMPHeader, type) == 0);
__Check_Compile_Time(offsetof(SVPICMPHeader, code) == 1);
__Check_Compile_Time(offsetof(SVPICMPHeader, checksum) == 2);
__Check_Compile_Time(offsetof(SVPICMPHeader, identifier) == 4);
__Check_Compile_Time(offsetof(SVPICMPHeader, sequenceNumber) == 6);

enum {
    SVPICMPv4TypeEchoRequest = 8,          ///< The ICMP `type` for a ping request; in this case `code` is always 0.
    SVPICMPv4TypeEchoReply   = 0           ///< The ICMP `type` for a ping response; in this case `code` is always 0.
};

enum {
    SVPICMPv6TypeEchoRequest = 128,        ///< The ICMP `type` for a ping request; in this case `code` is always 0.
    SVPICMPv6TypeEchoReply   = 129         ///< The ICMP `type` for a ping response; in this case `code` is always 0.
};


NS_ASSUME_NONNULL_END
