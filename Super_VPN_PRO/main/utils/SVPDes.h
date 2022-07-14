//
//  SVPDes.h
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/13.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
NS_ASSUME_NONNULL_BEGIN

@interface SVPDes : NSObject
+ (NSString *) encode:(NSString *)str key:(NSString *)key;
+ (NSString *) decode:(NSString *)str key:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
