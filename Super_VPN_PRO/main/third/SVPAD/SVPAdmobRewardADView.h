//
//  SVPAdmobRewardADView.h
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SVPAdmobRewardADView : UIView
- (void)setup_svpAdmobRewardedAdView:(UIViewController *)controller AdUnitID:(NSString *)adUnitID;
@property (nonatomic,strong)NSString *rewardedID;
@end

NS_ASSUME_NONNULL_END
