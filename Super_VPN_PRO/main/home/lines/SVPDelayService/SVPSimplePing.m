//
//  SVPSimplePing.m
//  SimplePingTest
//
//
// 
//

#import "SVPSimplePing.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <errno.h>
#include <arpa/inet.h>

#pragma mark * IPv4 and ICMPv4 On-The-Wire Format

struct SVPIPv4Header {
    uint8_t     versionAndHeaderLength;
    uint8_t     differentiatedServices;
    uint16_t    totalLength;
    uint16_t    identification;
    uint16_t    flagsAndFragmentOffset;
    uint8_t     timeToLive;
    uint8_t     protocol;
    uint16_t    headerChecksum;
    uint8_t     sourceAddress[4];
    uint8_t     destinationAddress[4];
    // options...
    // data...
};

typedef struct SVPIPv4Header SVPIPv4Header;

__Check_Compile_Time(sizeof(SVPIPv4Header) == 20);
__Check_Compile_Time(offsetof(SVPIPv4Header, versionAndHeaderLength) == 0);
__Check_Compile_Time(offsetof(SVPIPv4Header, differentiatedServices) == 1);
__Check_Compile_Time(offsetof(SVPIPv4Header, totalLength) == 2);
__Check_Compile_Time(offsetof(SVPIPv4Header, identification) == 4);
__Check_Compile_Time(offsetof(SVPIPv4Header, flagsAndFragmentOffset) == 6);
__Check_Compile_Time(offsetof(SVPIPv4Header, timeToLive) == 8);
__Check_Compile_Time(offsetof(SVPIPv4Header, protocol) == 9);
__Check_Compile_Time(offsetof(SVPIPv4Header, headerChecksum) == 10);
__Check_Compile_Time(offsetof(SVPIPv4Header, sourceAddress) == 12);
__Check_Compile_Time(offsetof(SVPIPv4Header, destinationAddress) == 16);

static uint16_t st_in_cksum(const void *buffer, size_t bufferLen) {
    //
    size_t              bytesLeft;
    int32_t             sum;
    const uint16_t *    cursor;
    union {
        uint16_t        us;
        uint8_t         uc[2];
    } last;
    uint16_t            answer;
    
    bytesLeft = bufferLen;
    sum = 0;
    cursor = buffer;
    /*
     * Our algorithm is simple, using a 32 bit accumulator (sum), we add
     * sequential 16 bit words to it, and at the end, fold back all the
     * carry bits from the top 16 bits into the lower 16 bits.
     */
    while (bytesLeft > 1) {
        sum += *cursor;
        cursor += 1;
        bytesLeft -= 2;
    }
    
    /* mop up an odd byte, if necessary */
    if (bytesLeft == 1) {
        last.uc[0] = * (const uint8_t *) cursor;
        last.uc[1] = 0;
        sum += last.us;
    }
    
    /* add back carry outs from top 16 bits to low 16 bits */
    sum = (sum >> 16) + (sum & 0xffff); /* add hi 16 to low 16 */
    sum += (sum >> 16);         /* add carry */
    answer = (uint16_t) ~sum;   /* truncate to 16 bits */
    
    return answer;
}

#pragma mark * SimplePing

@interface SVPSimplePing ()

// read/write versions of public properties

@property (nonatomic, copy,   readwrite, nullable) NSData * hostAddress;
@property (nonatomic, copy, readwrite, nullable) NSString * IPAddress;
@property (nonatomic, assign, readwrite          ) uint16_t nextSequenceNumber;

@property (nonatomic, assign, readwrite)           BOOL  nextSequenceNumberHasWrapped;

/*! A host object for name-to-address resolution.
 */

@property (nonatomic, strong, readwrite, nullable) CFHostRef host __attribute__ ((NSObject));

@property (nonatomic, strong, readwrite, nullable) CFSocketRef socket __attribute__ ((NSObject));

@property (nonatomic, strong) NSDate *pingStartDate;

@end

@implementation SVPSimplePing

- (instancetype)initWithSVPHostName:(NSString *)hostName {
    NSParameterAssert(hostName != nil);
    self = [super init];
    if (self != nil) {
        _hostName   = [hostName copy];
        _identifier = (uint16_t) arc4random();
    }
    return self;
}

- (void)dealloc {
    [self stop];
    // Double check that -stop took care of _host and _socket.
    assert(_host == NULL);
    assert(_socket == NULL);
}

- (sa_family_t)hostAddressFamily {
    sa_family_t     result;
    
    result = AF_UNSPEC;
    if ( (self.hostAddress != nil) && (self.hostAddress.length >= sizeof(struct sockaddr)) ) {
        result = ((const struct sockaddr *) self.hostAddress.bytes)->sa_family;
    }
    return result;
}

/*! Shuts down the pinger object and tell the delegate about the error.
 *  \param error Describes the failure.
 */

- (void)didFailWithError:(NSError *)error {
    id<SVPSimplePingDelegate>  strongDelegate;
    
    assert(error != nil);
    
    // We retain ourselves temporarily because it's common for the delegate method
    // to release its last reference to us, which causes -dealloc to be called here.
    // If we then reference self on the return path, things go badly.  I don't think
    // that happens currently, but I've got into the habit of doing this as a
    // defensive measure.
    
    CFAutorelease( CFBridgingRetain( self ));
    
    [self stop];
    strongDelegate = self.delegate;
    if ( (strongDelegate != nil) && [strongDelegate respondsToSelector:@selector(svp_simplePing:didFailWithError:)] ) {
        [strongDelegate svp_simplePing:self didFailWithError:error];
    }
}

- (void)didFailWithHostStreamError:(CFStreamError)streamError {
    NSDictionary *  userInfo;
    NSError *       error;
    
    if (streamError.domain == kCFStreamErrorDomainNetDB) {
        userInfo = @{(id) kCFGetAddrInfoFailureKey: @(streamError.error)};
    } else {
        userInfo = nil;
    }
    error = [NSError errorWithDomain:(NSString *) kCFErrorDomainCFNetwork code:kCFHostErrorUnknown userInfo:userInfo];
    
    [self didFailWithError:error];
}

- (NSData *)pingPacketWithType:(uint8_t)type payload:(NSData *)payload requiresChecksum:(BOOL)requiresChecksum {
    NSMutableData *         packet;
    SVPICMPHeader *            icmpPtr;
    
    packet = [NSMutableData dataWithLength:sizeof(*icmpPtr) + payload.length];
    assert(packet != nil);
    
    icmpPtr = packet.mutableBytes;
    icmpPtr->type = type;
    icmpPtr->code = 0;
    icmpPtr->checksum = 0;
    icmpPtr->identifier     = OSSwapHostToBigInt16(self.identifier);
    icmpPtr->sequenceNumber = OSSwapHostToBigInt16(self.nextSequenceNumber);
    memcpy(&icmpPtr[1], [payload bytes], [payload length]);
    
    if (requiresChecksum) {
        // The IP checksum routine returns a 16-bit number that's already in correct byte order
        // (due to wacky 1's complement maths), so we just put it into the packet as a 16-bit unit.
        
        icmpPtr->checksum = st_in_cksum(packet.bytes, packet.length);
    }
    
    return packet;
}

- (NSData *)packetWithPingData:(NSData *)data {
    NSData *                payload;
    NSData *                packet;
    
    // data may be nil
    NSParameterAssert(self.hostAddress != nil);     // gotta wait for -simplePing:didStartWithAddress:
    
    // Construct the ping packet.
    
    payload = data;
    if (payload == nil) {
        payload = [[NSString stringWithFormat:@"%28zd bottles of beer on the wall", (ssize_t) 99 - (size_t) (self.nextSequenceNumber % 100) ] dataUsingEncoding:NSASCIIStringEncoding];
        assert(payload != nil);
        
        // Our dummy payload is sized so that the resulting ICMP packet, including the ICMPHeader, is
        // 64-bytes, which makes it easier to recognise our packets on the wire.
        
        assert([payload length] == 56);
    }
    switch (self.hostAddressFamily) {
        case AF_INET: {
            packet = [self pingPacketWithType:SVPICMPv4TypeEchoRequest payload:payload requiresChecksum:YES];
        } break;
        case AF_INET6: {
            packet = [self pingPacketWithType:SVPICMPv6TypeEchoRequest payload:payload requiresChecksum:NO];
        } break;
        default: {
            assert(NO);
        } break;
    }
    assert(packet != nil);
    return packet;
}

- (void)sendPacket:(nonnull NSData *)packet {
    int                     err;
    ssize_t                 bytesSent;
    id<SVPSimplePingDelegate>  strongDelegate;
    // Send the packet.
    
    if (self.socket == NULL) {
        bytesSent = -1;
        err = EBADF;
    } else {
        self.pingStartDate = [NSDate date];
        bytesSent = sendto(
                           CFSocketGetNative(self.socket),
                           packet.bytes,
                           packet.length,
                           0,
                           self.hostAddress.bytes,
                           (socklen_t) self.hostAddress.length
                           );
        err = 0;
        if (bytesSent < 0) {
            err = errno;
        }
    }
    
    // Handle the results of the send.
    
    strongDelegate = self.delegate;
    if ( (bytesSent > 0) && (((NSUInteger) bytesSent) == packet.length) ) {
        
        // Complete success.  Tell the client.
        
        if ( (strongDelegate != nil) && [strongDelegate respondsToSelector:@selector(svp_simplePing:didSendPacket:sequenceNumber:)] ) {
            [strongDelegate svp_simplePing:self didSendPacket:packet sequenceNumber:self.nextSequenceNumber];
        }
    } else {
        NSError *   error;
        
        // Some sort of failure.  Tell the client.
        if (err == 0) {
            err = ENOBUFS;          // This is not a hugely descriptor error, alas.
        }
        error = [NSError errorWithDomain:NSPOSIXErrorDomain code:err userInfo:nil];
        if ( (strongDelegate != nil) && [strongDelegate respondsToSelector:@selector(svp_simplePing:didFailToSendPacket:sequenceNumber:error:)] ) {
            [strongDelegate svp_simplePing:self didFailToSendPacket:packet sequenceNumber:self.nextSequenceNumber error:error];
        }
    }
    
    self.nextSequenceNumber += 1;
    if (self.nextSequenceNumber == 0) {
        self.nextSequenceNumberHasWrapped = YES;
    }
}

+ (NSUInteger)icmpHeaderOffsetInIPv4Packet:(NSData *)packet timeToLive:(NSInteger *)timeToLive {
    // Returns the offset of the ICMPv4Header within an IP packet.
    NSUInteger                  result;
    const struct SVPIPv4Header *   ipPtr;
    size_t                      ipHeaderLength;
    
    result = NSNotFound;
    if (packet.length >= (sizeof(SVPIPv4Header) + sizeof(SVPICMPHeader))) {
        ipPtr = (const SVPIPv4Header *) packet.bytes;
        if ( ((ipPtr->versionAndHeaderLength & 0xF0) == 0x40) &&            // IPv4
            ( ipPtr->protocol == IPPROTO_ICMP ) ) {
            ipHeaderLength = (ipPtr->versionAndHeaderLength & 0x0F) * sizeof(uint32_t);
            if (packet.length >= (ipHeaderLength + sizeof(SVPICMPHeader))) {
                result = ipHeaderLength;
            }
        }
        if (timeToLive) {
            *timeToLive = ipPtr->timeToLive;
        }
    }
    return result;
}

/*! Checks whether the specified sequence number is one we sent.
 *  \param sequenceNumber The incoming sequence number.
 *  \returns YES if the sequence number looks like one we sent.
 */

- (BOOL)validateSequenceNumber:(uint16_t)sequenceNumber {
    if (self.nextSequenceNumberHasWrapped) {
        return ((uint16_t) (self.nextSequenceNumber - sequenceNumber)) < (uint16_t) 120;
    } else {
        return sequenceNumber < self.nextSequenceNumber;
    }
}

- (BOOL)validatePing4ResponsePacket:(NSMutableData *)packet sequenceNumber:(uint16_t *)sequenceNumberPtr timeToLive:(NSInteger *)timeToLive {
    BOOL                result;
    NSUInteger          icmpHeaderOffset;
    SVPICMPHeader *        icmpPtr;
    uint16_t            receivedChecksum;
    uint16_t            calculatedChecksum;
    
    result = NO;
    
    icmpHeaderOffset = [[self class] icmpHeaderOffsetInIPv4Packet:packet timeToLive:timeToLive];
    if (icmpHeaderOffset != NSNotFound) {
        icmpPtr = (struct SVPICMPHeader *) (((uint8_t *) packet.mutableBytes) + icmpHeaderOffset);
        receivedChecksum   = icmpPtr->checksum;
        icmpPtr->checksum  = 0;
        calculatedChecksum = st_in_cksum(icmpPtr, packet.length - icmpHeaderOffset);
        icmpPtr->checksum  = receivedChecksum;
        
        if (receivedChecksum == calculatedChecksum) {
            if ( (icmpPtr->type == SVPICMPv4TypeEchoReply) && (icmpPtr->code == 0) ) {
                if ( OSSwapBigToHostInt16(icmpPtr->identifier) == self.identifier ) {
                    uint16_t    sequenceNumber;
                    
                    sequenceNumber = OSSwapBigToHostInt16(icmpPtr->sequenceNumber);
                    if ([self validateSequenceNumber:sequenceNumber]) {
                        
                        // Remove the IPv4 header off the front of the data we received, leaving us with
                        // just the ICMP header and the ping payload.
                        [packet replaceBytesInRange:NSMakeRange(0, icmpHeaderOffset) withBytes:NULL length:0];
                        
                        *sequenceNumberPtr = sequenceNumber;
                        result = YES;
                    }
                }
            }
        }
    }
    
    return result;
}

- (BOOL)validatePing6ResponsePacket:(NSMutableData *)packet sequenceNumber:(uint16_t *)sequenceNumberPtr {
    BOOL                    result;
    const SVPICMPHeader *      icmpPtr;
    
    result = NO;
    
    if (packet.length >= sizeof(*icmpPtr)) {
        icmpPtr = packet.bytes;
        
        // In the IPv6 case we don't check the checksum because that's hard (we need to
        // cook up an IPv6 pseudo header and we don't have the ingredients) and unnecessary
        // (the kernel has already done this check).
        
        if ( (icmpPtr->type == SVPICMPv6TypeEchoReply) && (icmpPtr->code == 0) ) {
            if ( OSSwapBigToHostInt16(icmpPtr->identifier) == self.identifier ) {
                uint16_t    sequenceNumber;
                
                sequenceNumber = OSSwapBigToHostInt16(icmpPtr->sequenceNumber);
                if ([self validateSequenceNumber:sequenceNumber]) {
                    *sequenceNumberPtr = sequenceNumber;
                    result = YES;
                }
            }
        }
    }
    return result;
}

- (BOOL)validatePingResponsePacket:(NSMutableData *)packet sequenceNumber:(uint16_t *)sequenceNumberPtr timeToLive:(NSInteger *)timeToLive {
    BOOL        result;
    
    switch (self.hostAddressFamily) {
        case AF_INET: {
            result = [self validatePing4ResponsePacket:packet sequenceNumber:sequenceNumberPtr timeToLive:timeToLive];
        } break;
        case AF_INET6: {
            result = [self validatePing6ResponsePacket:packet sequenceNumber:sequenceNumberPtr];
        } break;
        default: {
            assert(NO);
            result = NO;
        } break;
    }
    return result;
}

/*! Reads data from the ICMP socket.
 *  \details Called by the socket handling code (SocketReadCallback) to process an ICMP
 *      message waiting on the socket.
 */

- (void)readData {
    int                     err;
    struct sockaddr_storage addr;
    socklen_t               addrLen;
    ssize_t                 bytesRead;
    void *                  buffer;
    enum { kBufferSize = 65535 };

    buffer = malloc(kBufferSize);
    assert(buffer != NULL);
    addrLen = sizeof(addr);
    bytesRead = recvfrom(CFSocketGetNative(self.socket), buffer, kBufferSize, 0, (struct sockaddr *) &addr, &addrLen);
    err = 0;
    if (bytesRead < 0) {
        err = errno;
    }
    
    // Process the data we read.
    
    if (bytesRead > 0) {
        NSMutableData *         packet;
        id<SVPSimplePingDelegate>  strongDelegate;
        uint16_t                sequenceNumber;
        NSInteger timeToLive = 0;
        
        packet = [NSMutableData dataWithBytes:buffer length:(NSUInteger) bytesRead];
        assert(packet != nil);
        
        // We got some data, pass it up to our client.
        
        strongDelegate = self.delegate;
        if ( [self validatePingResponsePacket:packet sequenceNumber:&sequenceNumber timeToLive:&timeToLive] ) {
            if ( (strongDelegate != nil) && [strongDelegate respondsToSelector:@selector(svp_simplePing:didReceivePingResponsePacket:timeToLive:sequenceNumber:timeElapsed:)] ) {
                NSTimeInterval timeElapsed = [[NSDate date] timeIntervalSinceDate:self.pingStartDate];
                [strongDelegate svp_simplePing:self didReceivePingResponsePacket:packet timeToLive:timeToLive sequenceNumber:sequenceNumber timeElapsed:timeElapsed];
            }
        } else {
            if ( (strongDelegate != nil) && [strongDelegate respondsToSelector:@selector(svp_simplePing:didReceiveUnexpectedPacket:)] ) {
                [strongDelegate svp_simplePing:self didReceiveUnexpectedPacket:packet];
            }
        }
    } else {
        
        // We failed to read the data, so shut everything down.
        
        if (err == 0) {
            err = EPIPE;
        }
        [self didFailWithError:[NSError errorWithDomain:NSPOSIXErrorDomain code:err userInfo:nil]];
    }
    
    free(buffer);
}

static void STSocketReadCallback(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    SVPSimplePing *    obj;
    
    obj = (__bridge SVPSimplePing *) info;
    assert([obj isKindOfClass:[SVPSimplePing class]]);
    
#pragma unused(s)
    assert(s == obj.socket);
#pragma unused(type)
    assert(type == kCFSocketReadCallBack);
#pragma unused(address)
    assert(address == nil);
#pragma unused(data)
    assert(data == nil);
    
    [obj readData];
}


- (void)startWithHostAddress {
    int                     err;
    int                     fd;
    assert(self.hostAddress != nil);
    fd = -1;
    err = 0;
    switch (self.hostAddressFamily) {
        case AF_INET: {
            fd = socket(AF_INET, SOCK_DGRAM, IPPROTO_ICMP);
            if (fd < 0) {
                err = errno;
            }
        } break;
        case AF_INET6: {
            fd = socket(AF_INET6, SOCK_DGRAM, IPPROTO_ICMPV6);
            if (fd < 0) {
                err = errno;
            }
        } break;
        default: {
            err = EPROTONOSUPPORT;
        } break;
    }
    
    if (err != 0) {
        [self didFailWithError:[NSError errorWithDomain:NSPOSIXErrorDomain code:err userInfo:nil]];
    } else {
        CFSocketContext         context = {0, (__bridge void *)(self), NULL, NULL, NULL};
        CFRunLoopSourceRef      rls;
        id<SVPSimplePingDelegate>  strongDelegate;
        
        // Wrap it in a CFSocket and schedule it on the runloop.
        
        self.socket = (CFSocketRef) CFAutorelease( CFSocketCreateWithNative(NULL, fd, kCFSocketReadCallBack, STSocketReadCallback, &context) );
        assert(self.socket != NULL);
        
        // The socket will now take care of cleaning up our file descriptor.
        
        assert( CFSocketGetSocketFlags(self.socket) & kCFSocketCloseOnInvalidate );
        fd = -1;
        
        rls = CFSocketCreateRunLoopSource(NULL, self.socket, 0);
        assert(rls != NULL);
        
        CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
        
        CFRelease(rls);
        
        strongDelegate = self.delegate;
        if ( (strongDelegate != nil) && [strongDelegate respondsToSelector:@selector(svp_simplePing:didStartWithAddress:)] ) {
            [strongDelegate svp_simplePing:self didStartWithAddress:self.hostAddress];
        }
    }
    assert(fd == -1);
}

- (void)hostResolutionDone {
    Boolean     resolved;
    NSArray *   addresses;
    
    // Find the first appropriate address.
    
    addresses = (__bridge NSArray *) CFHostGetAddressing(self.host, &resolved);
    if ( resolved && (addresses != nil) ) {
        resolved = false;
        for (NSData * address in addresses) {
            const struct sockaddr * addrPtr;
            
            addrPtr = (const struct sockaddr *) address.bytes;
            if ( address.length >= sizeof(struct sockaddr) ) {
                char *s = NULL;
                switch (addrPtr->sa_family) {
                    case AF_INET: {
                        struct sockaddr_in *addr_in = (struct sockaddr_in *)addrPtr;
                        s = malloc(INET_ADDRSTRLEN);
                        inet_ntop(AF_INET, &(addr_in->sin_addr), s, INET_ADDRSTRLEN);
                        self.IPAddress = [NSString stringWithFormat:@"%s", s];
                        if (self.addressStyle != SVPSimplePingAddressStyleICMPv6) {
                            self.hostAddress = address;
                            resolved = true;
                        }
                    } break;
                    case AF_INET6: {
                        struct sockaddr_in6 *addr_in6 = (struct sockaddr_in6 *)addrPtr;
                        s = malloc(INET6_ADDRSTRLEN);
                        inet_ntop(AF_INET6, &(addr_in6->sin6_addr), s, INET6_ADDRSTRLEN);
                        self.IPAddress = [NSString stringWithFormat:@"%s", s];
                        if (self.addressStyle != SVPSimplePingAddressStyleICMPv4) {
                            self.hostAddress = address;
                            resolved = true;
                        }
                    } break;
                }
            }
            if (resolved) {
                break;
            }
        }
    }
    
    // We're done resolving, so shut that down.
    
    [self stopHostResolution];
    
    // If all is OK, start the send and receive infrastructure, otherwise stop.
    
    if (resolved) {
        [self startWithHostAddress];
    } else {
        [self didFailWithError:[NSError errorWithDomain:(NSString *)kCFErrorDomainCFNetwork code:kCFHostErrorHostNotFound userInfo:nil]];
    }
}

/*! The callback for our CFHost object.
 *  \details This simply routes the call to our `-hostResolutionDone` or
 *      `-didFailWithHostStreamError:` methods.
 *  \param theHost See the documentation for CFHostClientCallBack.
 *  \param typeInfo See the documentation for CFHostClientCallBack.
 *  \param error See the documentation for CFHostClientCallBack.
 *  \param info See the documentation for CFHostClientCallBack; this is actually a pointer to
 *      the 'owning' object.
 */

static void STHostResolveCallback(CFHostRef theHost, CFHostInfoType typeInfo, const CFStreamError *error, void *info) {
    // This C routine is called by CFHost when the host resolution is complete.
    // It just redirects the call to the appropriate Objective-C method.
    SVPSimplePing *    obj;
    
    obj = (__bridge SVPSimplePing *) info;
    assert([obj isKindOfClass:[SVPSimplePing class]]);
    
#pragma unused(theHost)
    assert(theHost == obj.host);
#pragma unused(typeInfo)
    assert(typeInfo == kCFHostAddresses);
    
    if ( (error != NULL) && (error->domain != 0) ) {
        [obj didFailWithHostStreamError:*error];
    } else {
        [obj hostResolutionDone];
    }
}

- (void)start {
    Boolean             success;
    CFHostClientContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    CFStreamError       streamError;
    
    assert(self.host == NULL);
    assert(self.hostAddress == nil);
    
    self.host = (CFHostRef) CFAutorelease( CFHostCreateWithName(NULL, (__bridge CFStringRef) self.hostName) );
    assert(self.host != NULL);
    
    CFHostSetClient(self.host, STHostResolveCallback, &context);
    
    CFHostScheduleWithRunLoop(self.host, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    
    success = CFHostStartInfoResolution(self.host, kCFHostAddresses, &streamError);
    if ( ! success ) {
        [self didFailWithHostStreamError:streamError];
    }
}

/*! Stops the name-to-address resolution infrastructure.
 */

- (void)stopHostResolution {
    // Shut down the CFHost.
    if (self.host != NULL) {
        CFHostSetClient(self.host, NULL, NULL);
        CFHostUnscheduleFromRunLoop(self.host, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        self.host = NULL;
    }
}

/*! Stops the send and receive infrastructure.
 */

- (void)stopSocket {
    if (self.socket != NULL) {
        CFSocketInvalidate(self.socket);
        self.socket = NULL;
    }
}

- (void)stop {
    [self stopHostResolution];
    [self stopSocket];
    
    // Junk the host address on stop.  If the client calls -start again, we'll
    // re-resolve the host name.
    self.IPAddress = nil;
    self.hostAddress = NULL;
}

@end
