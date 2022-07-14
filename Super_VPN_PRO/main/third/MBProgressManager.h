//
//  MBProgressManager.h
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/10.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
NS_ASSUME_NONNULL_BEGIN

@interface MBProgressManager : NSObject

+ (void)showGloomy:(BOOL) isShow;
+ (void)showLoading;
+ (void)showWaitingWithTitle:(NSString *)title;
+ (void)showPermanentAlert:(NSString *) alert;
+ (void)showBriefAlert:(NSString *) alert;
+ (void)showAlertWithCustomImage:(NSString *)imageName title:(NSString *)title;
+ (void)showBriefAlert:(NSString *)message time:(NSInteger)showTime;
+ (void)hideAlert;
+ (void)showBriefAlert:(NSString *)message inView:(UIView *)view;
+ (void)showPermanentMessage:(NSString *)message inView:(UIView *)view;
+ (void)showLoadingInView:(UIView *)view;
+ (void)showWaitingWithTitle:(NSString *)title inView:(UIView *)view;
+ (void)showAlertWithCustomImage:(NSString *)imageName title:(NSString *)title inView:(UIView *)view;
+ (void)showBriefAlert:(NSString *)message time:(NSInteger)showTime inView:(UIView *)view;
@end

@interface GloomyView : UIView<UIGestureRecognizerDelegate>
@end
NS_ASSUME_NONNULL_END
