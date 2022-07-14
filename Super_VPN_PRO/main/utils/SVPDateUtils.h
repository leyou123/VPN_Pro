//
//  SVPDateUtils.h
//  Super_VPN_PRO
//
//  Created by LC on 2022/4/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SVPDateUtils : NSObject

+ (NSString *)getExpireDate;

+ (void)saveExpireWithInterval:(NSInteger)interval;

+ (NSString *)getRemainMinute;

+ (void)setRemainMinute:(NSInteger)interval;

+ (NSInteger)getTimeInterval:(NSString *)pruductId;

@end

NS_ASSUME_NONNULL_END
