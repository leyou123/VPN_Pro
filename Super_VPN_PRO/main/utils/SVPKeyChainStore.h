//
//  KeyChainStore.h
//  Super_VPN_PRO
//
//  Created by LC on 2022/4/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SVPKeyChainStore : NSObject

+ (void)save:(NSString*)service data:(id)data;
+ (id)load:(NSString*)service;
+ (void)deleteKeyData:(NSString*)service;
+ (NSString *)getUUIDByKeyChain;

@end

NS_ASSUME_NONNULL_END
