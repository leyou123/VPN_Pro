//
//  SVPDateUtils.m
//  Super_VPN_PRO
//
//  Created by LC on 2022/4/15.
//

#import "SVPDateUtils.h"

@implementation SVPDateUtils

+ (NSString *)getExpireDate {
    NSString * expireTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"EXPIREDATE"];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate * date = [dateformatter dateFromString:expireTime];
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                                 initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    unsigned unitFlags = NSCalendarUnitYear |
    NSCalendarUnitMonth |  NSCalendarUnitDay |
    NSCalendarUnitHour |  NSCalendarUnitMinute |
    NSCalendarUnitSecond | NSCalendarUnitWeekday;
    NSDateComponents* comp = [gregorian components: unitFlags
                                          fromDate:date];
    NSInteger year = comp.year;
    NSInteger month = comp.month;
    NSInteger day = comp.day;
    
    return [NSString stringWithFormat:@"%ld-%02ld-%02ld",year,month,day];
}

+ (void)saveExpireWithInterval:(NSInteger)interval {
    
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString * startTime = [SVPDateUtils getStartTime];
    
    NSDate * startDate = [dateFormatter dateFromString:startTime];
    NSDate *resultDate = [NSDate dateWithTimeInterval:60 * (interval) sinceDate:startDate];
    NSString *  exprieDate=[dateFormatter stringFromDate:resultDate];
    
    [userDefault setObject:exprieDate forKey:@"EXPIREDATE"];
    [userDefault synchronize];
    
    [self setRemainMinute:interval];
}

+ (NSString *)getRemainMinute {
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    NSString * interval = [userDefault objectForKey:@"REMAINMINS"];
    return interval;
}

+ (void)setRemainMinute:(NSInteger)interval {
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    NSString * time = [SVPDateUtils getRemainMinute];
    NSString * total = [NSString stringWithFormat:@"%ld",[time integerValue] + interval];
    [userDefault setObject:total forKey:@"REMAINMINS"];
    [userDefault synchronize];
}

+ (NSString *)getStartTime {
    NSString * dateString = @"";
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault objectForKey:@"EXPIREDATE"]) {
        dateString = [userDefault objectForKey:@"EXPIREDATE"];
    }else {
        NSDate *  currentTime=[NSDate date];
        NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
        dateString = [dateformatter stringFromDate:currentTime];
    }
    return dateString;
}

+ (NSInteger)getTimeInterval:(NSString *)pruductId {
    NSInteger timeInterval = 0;
    if ([pruductId isEqualToString:@"com.superpro.30"]) {
        timeInterval = 30*24*60;
    }else if ([pruductId isEqualToString:@"com.superpro.90"]) {
        timeInterval = 90*24*60;
    }else if ([pruductId isEqualToString:@"com.superpro.180"]) {
        timeInterval = 180*24*60;
    }else if ([pruductId isEqualToString:@"com.superpro.360"]) {
        timeInterval = 360*24*60;
    }
    return timeInterval;
}



@end
