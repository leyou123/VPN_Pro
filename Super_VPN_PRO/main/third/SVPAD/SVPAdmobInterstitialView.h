//
//  SVPAdmobInterstitialView.h
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class SVPAdmobInterstitialView;
@protocol SVPAdmobInterstitialViewDelegate <NSObject>
- (void)setup_svpInterstitialDidClosed:(SVPAdmobInterstitialView *)svpInterstitialView;
@end

@interface SVPAdmobInterstitialView : UIView
- (void)setup_svpAdmobInterstitialView:(UIViewController *)controller AdUnitID:(NSString *)AdUnitID;
@property (nonatomic, weak) id<SVPAdmobInterstitialViewDelegate> delegate;
@property (nonatomic,strong)NSString *svp_InterstitialID;
@end

NS_ASSUME_NONNULL_END
