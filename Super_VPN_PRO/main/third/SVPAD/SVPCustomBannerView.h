//
//  SVPCustomBannerView.h
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class SVPCustomBannerView;

@protocol CustomBannerViewDelegate <NSObject>
- (void)setup_svpBannerViewClick:(SVPCustomBannerView *)bannerView;

@end

@interface SVPCustomBannerView : UIView
@property (nonatomic, weak) id<CustomBannerViewDelegate> delegate;
@property (strong, nonatomic)NSString *svp_BannerImageUrl;
@property (nonatomic,strong)NSString *svp_BannerTag;
@property (nonatomic,strong)NSString *svp_BannerUrl;
@property (nonatomic,strong)NSString *svp_customBannerID;

@end

NS_ASSUME_NONNULL_END
