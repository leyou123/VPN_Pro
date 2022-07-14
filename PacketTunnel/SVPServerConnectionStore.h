//
//  SVPServerConnectionStore.h
//  PacketTunnel
//
//  Created by MacOSDaye on 2021/9/22.
//

#import <Foundation/Foundation.h>
#import "SVPServerConnection.h"
NS_ASSUME_NONNULL_BEGIN

@interface SVPServerConnectionStore : NSObject
@property (assign, nonatomic)SVPServerConnectionStatus status;
@property (assign, nonatomic)BOOL isUdpSupported;

- (instancetype)initWithAppGroup:(NSString *)appGroupName;
- (BOOL)save:(SVPServerConnection *)connection;
- (SVPServerConnection *)load;
@end

NS_ASSUME_NONNULL_END
