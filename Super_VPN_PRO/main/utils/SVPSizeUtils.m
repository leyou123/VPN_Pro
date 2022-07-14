//
//  SVPSizeUtils.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/18.
//

#import "SVPSizeUtils.h"
#import <UIKit/UIKit.h>
@implementation SVPSizeUtils

+ (float)svp_height {
    return [UIScreen mainScreen].bounds.size.height;
}
+ (float)svp_width {
    return [UIScreen mainScreen].bounds.size.width;
}
+ (float)svp_statusFrameHeight {
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}

+ (BOOL)svp_isIPhoneNotchScreen{
    BOOL result = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return result;
    }
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            result = YES;
        }
    }
    
    
    return result;
}
@end
