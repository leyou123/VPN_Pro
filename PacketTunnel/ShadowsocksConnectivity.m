#include <arpa/inet.h>
#import "ShadowsocksConnectivity.h"
//#import <Shadowsocks_iOS/shadowsocks.h>

@import CocoaAsyncSocket;
static char *const kShadowsocksLocalAddress = "127.0.0.1";
static const uint8_t kSocksMethodsResponseNumBytes = 2;
static const size_t kSocksConnectResponseNumBytes = 10;
static const uint8_t kSocksVersion = 0x5;
static const uint8_t kSocksMethodNoAuth = 0x0;
static const uint8_t kSocksCmdConnect = 0x1;
static const uint8_t kSocksAtypDomainname = 0x3;
static const NSTimeInterval kTcpSocketTimeoutSecs = 10.0;
static const long kSocketTagHttpRequest = 100;
static const uint16_t kHttpPort = 80;

struct socks_udp_header {
    uint16_t rsv;
    uint8_t frag;
    uint8_t atyp;
    uint32_t addr;
    uint16_t port;
};

struct socks_methods_request {
    uint8_t ver;
    uint8_t nmethods;
    uint8_t method;
};

struct socks_request_header {
    uint8_t ver;
    uint8_t cmd;
    uint8_t rsv;
    uint8_t atyp;
};

@interface ShadowsocksConnectivity ()<GCDAsyncSocketDelegate, GCDAsyncUdpSocketDelegate>

@property(nonatomic) uint16_t shadowsocksPort;

@property(nonatomic, copy) void (^udpForwardingCompletion)(BOOL);
@property(nonatomic, copy) void (^reachabilityCompletion)(BOOL);
@property(nonatomic, copy) void (^credentialsCompletion)(BOOL);

@property(nonatomic) dispatch_queue_t dispatchQueue;
@property(nonatomic) GCDAsyncUdpSocket *asyncUdpSocket;
@property(nonatomic) GCDAsyncSocket *svp_CredentialsSocket;
@property(nonatomic) GCDAsyncSocket *svp_ReachabilitySocket;

@property(nonatomic) bool svp_IsRemoteUdpForwardingEnabled;
@property(nonatomic) bool svp_AreServerCredentialsValid;
@property(nonatomic) bool svp_IsServerReachable;
@property(nonatomic) int  svp_UdpForwardingNumChecks;
@end

@implementation ShadowsocksConnectivity

- (id)initWithPort:(uint16_t)shadowsocksPort {
  self = [super init];
  if (self) {
    _shadowsocksPort = shadowsocksPort;
    _dispatchQueue = dispatch_queue_create("ShadowsocksConnectivity", DISPATCH_QUEUE_SERIAL);
  }
  return self;
}

#pragma mark - UDP Forwarding
- (void)isUdpForwardingEnabled:(void (^)(BOOL))completion {
  self.svp_IsRemoteUdpForwardingEnabled = true;
  self.svp_UdpForwardingNumChecks = 0;
  self.udpForwardingCompletion = completion;
  self.asyncUdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:self.dispatchQueue];
  [self udpForwardingCheckDone:true];
}

// Returns a byte representation of a DNS request for "baidu.com".
- (uint8_t *)getDnsRequest {
  static uint8_t kDnsRequest[] = {
      0, 0,  // [0-1]   query ID
      1, 0,  // [2-3]   flags; byte[2] = 1 for recursion desired (RD).
      0, 1,  // [4-5]   QDCOUNT (number of queries)
      0, 0,  // [6-7]   ANCOUNT (number of answers)
      0, 0,  // [8-9]   NSCOUNT (number of name server records)
      0, 0,  // [10-11] ARCOUNT (number of additional records)
      5, 'b', 'a', 'i', 'd', 'u', 3, 'c', 'o', 'm',
      0,     // null terminator of FQDN (root TLD)
      0, 1,  // QTYPE, set to A
      0, 1   // QCLASS, set to 1 = IN (Internet)
  };
  return kDnsRequest;
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock
    didNotSendDataWithTag:(long)tag
               dueToError:(NSError *)error {
  NSLog(@"Failed to send data on UDP socket");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock
       didReceiveData:(NSData *)data
          fromAddress:(NSData *)address
    withFilterContext:(id)filterContext {
    if (!self.svp_IsRemoteUdpForwardingEnabled) {
    [self udpForwardingCheckDone:true];
  }
}

- (void)udpForwardingCheckDone:(BOOL)enabled {
    self.svp_IsRemoteUdpForwardingEnabled = enabled;
  if (self.udpForwardingCompletion != NULL) {
    self.udpForwardingCompletion(self.svp_IsRemoteUdpForwardingEnabled);
    self.udpForwardingCompletion = NULL;
  }
}

#pragma mark - Credentials

- (void)checkServerCredentials:(void (^)(BOOL))completion {
    self.svp_AreServerCredentialsValid = false;
  self.credentialsCompletion = completion;
    self.svp_CredentialsSocket =
      [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.dispatchQueue];
  NSError *error;
    [self.svp_CredentialsSocket
      connectToHost:[[NSString alloc] initWithUTF8String:kShadowsocksLocalAddress]
             onPort:self.shadowsocksPort
        withTimeout:kTcpSocketTimeoutSecs
              error:&error];
  if (error) {
    [self serverCredentialsCheckDone];
    return;
  }

  struct socks_methods_request methodsRequest = {
      .ver = kSocksVersion,
      .nmethods = 0x1,
      .method = kSocksMethodNoAuth
  };
  NSData *methodsRequestData =
      [[NSData alloc] initWithBytes:&methodsRequest length:sizeof(struct socks_methods_request)];
    [self.svp_CredentialsSocket writeData:methodsRequestData withTimeout:kTcpSocketTimeoutSecs tag:0];
    [self.svp_CredentialsSocket readDataToLength:kSocksMethodsResponseNumBytes
                               withTimeout:kTcpSocketTimeoutSecs
                                       tag:0];

  size_t socksRequestHeaderNumBytes = sizeof(struct socks_request_header);
  NSString *domain = [self chooseRandomDomain];
  uint8_t domainNameNumBytes = domain.length;
  size_t socksRequestNumBytes = socksRequestHeaderNumBytes + domainNameNumBytes +
                                sizeof(uint16_t) /* port */ +
                                sizeof(uint8_t) /* domain name length */;

  struct socks_request_header socksRequestHeader = {
      .ver = kSocksVersion, .cmd = kSocksCmdConnect, .atyp = kSocksAtypDomainname};
  uint8_t socksRequest[socksRequestNumBytes];
  memset(socksRequest, 0x0, socksRequestNumBytes);
  memcpy(socksRequest, &socksRequestHeader, socksRequestHeaderNumBytes);
  socksRequest[socksRequestHeaderNumBytes] = domainNameNumBytes;
  memcpy(socksRequest + socksRequestHeaderNumBytes + sizeof(uint8_t), [domain UTF8String],
         domainNameNumBytes);
  uint16_t httpPort = htons(kHttpPort);
  memcpy(socksRequest + socksRequestHeaderNumBytes + sizeof(uint8_t) + domainNameNumBytes,
         &httpPort, sizeof(uint16_t));

  NSData *socksRequestData =
      [[NSData alloc] initWithBytes:socksRequest length:socksRequestNumBytes];
    [self.svp_CredentialsSocket writeData:socksRequestData withTimeout:kTcpSocketTimeoutSecs tag:0];
    [self.svp_CredentialsSocket readDataToLength:kSocksConnectResponseNumBytes
                               withTimeout:kTcpSocketTimeoutSecs
                                       tag:0];

  NSString *httpRequest =
      [[NSString alloc] initWithFormat:@"HEAD / HTTP/1.1\r\nHost: %@\r\n\r\n", domain];
    [self.svp_CredentialsSocket
        writeData:[NSData dataWithBytes:[httpRequest UTF8String] length:httpRequest.length]
      withTimeout:kTcpSocketTimeoutSecs
              tag:kSocketTagHttpRequest];
    [self.svp_CredentialsSocket readDataWithTimeout:kTcpSocketTimeoutSecs tag:kSocketTagHttpRequest];
    [self.svp_CredentialsSocket disconnectAfterReading];
}

+ (const NSArray *)getCredentialsValidationDomains {
  static const NSArray *kCredentialsValidationDomains;
  static dispatch_once_t kDispatchOnceToken;
  dispatch_once(&kDispatchOnceToken, ^{
    kCredentialsValidationDomains =
        @[ @"eff.org", @"ietf.org", @"w3.org", @"wikipedia.org", @"example.com" ];
  });
  return kCredentialsValidationDomains;
}

- (NSString *)chooseRandomDomain {
  const NSArray *domainsArray = [ShadowsocksConnectivity getCredentialsValidationDomains];
  int indexSerb = arc4random_uniform((uint32_t)domainsArray.count);
  return domainsArray[indexSerb];
}

- (void)serverCredentialsCheckDone {
  if (self.credentialsCompletion != NULL) {
      self.credentialsCompletion(self.svp_AreServerCredentialsValid);
    self.credentialsCompletion = NULL;
  }
}

#pragma mark - Reachability

- (void)isReachable:(NSString *)host port:(uint16_t)port completion:(void (^)(BOOL))completion {
  //NSLog(@"Starting server reachability check.");
    self.svp_IsServerReachable = false;
  self.reachabilityCompletion = completion;
    self.svp_ReachabilitySocket =
      [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.dispatchQueue];
  NSError *error;
    [self.svp_ReachabilitySocket connectToHost:host
                                  onPort:port
                             withTimeout:kTcpSocketTimeoutSecs
                                   error:&error];
  if (error) {
    return;
  }
}

- (void)reachabilityCheckDone {
    NSLog(@"Server %@.", self.svp_IsServerReachable ? @"reachable" : @"unreachable");
  if (self.reachabilityCompletion != NULL) {
      self.reachabilityCompletion(self.svp_IsServerReachable);
    self.reachabilityCompletion = NULL;
  }
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
  if (tag == kSocketTagHttpRequest && data != nil) {
    NSString *httpResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
      self.svp_IsServerReachable = httpResponse != nil && [httpResponse hasPrefix:@"HTTP/1.1"];
  }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    if ([self.svp_ReachabilitySocket isEqual:sock]) {
        self.svp_IsServerReachable = true;
        [self.svp_ReachabilitySocket disconnect];
  }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)error {
    if ([self.svp_ReachabilitySocket isEqual:sock]) {
    [self reachabilityCheckDone];
  } else {
    [self serverCredentialsCheckDone];
  }
}

@end
