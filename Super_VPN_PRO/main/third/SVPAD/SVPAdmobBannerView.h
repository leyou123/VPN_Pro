//
//  SVPAdmobBannerView.h
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SVPAdmobBannerView : UIView
@property (nonatomic,strong)NSString *bannerID;
- (void)setup_svpAdmobBannerView:(UIViewController *)controller AdUnitID:(NSString *)AdUnitID;
@end

NS_ASSUME_NONNULL_END
