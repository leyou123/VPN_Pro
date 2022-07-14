//
//  SVPVungleBannerView.h
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SVPVungleBannerView : UIView
@property (nonatomic,strong)NSString *svp_ID;
@property (nonatomic,strong)NSString *svp_unit_key;
- (void)setup_svpVungleBannerView:(UIViewController *)controller ProjectKey:(NSString *)projectKey;
@end

NS_ASSUME_NONNULL_END
