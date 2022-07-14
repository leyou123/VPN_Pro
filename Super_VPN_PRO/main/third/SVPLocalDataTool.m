//
//  SVPLocalDataTool.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/8.
//

#import "SVPLocalDataTool.h"

@implementation SVPLocalDataTool

+ (void)setObject:(id)value forKey:(NSString *)defaultKeyName{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:defaultKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+ (id)objectForKey:(NSString *)defaultKeyName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:defaultKeyName];
}

+(void)setValue:(id)value forKey:(NSString *)defaultKeyName
{
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:defaultKeyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(id)valueForKey:(NSString *)defaultKeyName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:defaultKeyName];
}

+(void)removeObjectForKey:(NSString *)keyName
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:keyName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)clearAll {
    NSUserDefaults *userDefatluts = [NSUserDefaults standardUserDefaults];
    NSDictionary *dictionary = userDefatluts.dictionaryRepresentation;;
    for(NSString* key in [dictionary allKeys]){
        if ([key isEqualToString:@"isFirst"]) {
            continue;
        }
        [userDefatluts removeObjectForKey:key];
        [userDefatluts synchronize];
    }
}

@end
