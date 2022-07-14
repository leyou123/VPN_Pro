//
//  SVPLocalDataTool.h
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SVPLocalDataTool : NSObject
+ (void)setObject:(id)value forKey:(NSString *)defaultKeyName;

+ (id)objectForKey:(NSString *)defaultKeyName;

+ (void)setValue:(id)value forKey:(NSString *)defaultKeyName;

+ (id)valueForKey:(NSString *)defaultKeyName;

+(void)removeObjectForKey:(NSString*)keyName;

+(void)clearAll;
@end

NS_ASSUME_NONNULL_END
