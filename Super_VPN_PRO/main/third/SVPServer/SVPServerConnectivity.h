//
//  SVPServerConnectivity.h
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/15.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/CocoaAsyncSocket.h>
NS_ASSUME_NONNULL_BEGIN

@interface SVPServerConnectivity : NSObject<GCDAsyncSocketDelegate>
- (BOOL)isServerReachable:(NSString *)host port:(uint16_t)port completion:(void(^)(BOOL))completion;

@end

NS_ASSUME_NONNULL_END
