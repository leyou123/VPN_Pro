//
//  SVPCustomInterstitalView.h
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class SVPCustomInterstitalView;

@protocol SVPCustomInterstitalViewDelegate <NSObject>
- (void)setup_svpInterstitialViewClick:(SVPCustomInterstitalView *)bannerView;

@end
@interface SVPCustomInterstitalView : UIView
@property (nonatomic, weak) id<SVPCustomInterstitalViewDelegate> delegate;

@property (nonatomic,strong)NSString *svp_AwardStatus;
@property (nonatomic,strong)NSString *svp_InterstitialImageUrl;
@property (nonatomic,strong)NSString *svp_InterstitialTag;
@property (nonatomic,strong)NSString *svp_InterstitialUrl;
@property (nonatomic,strong)NSString *svp_CustomInterstitialID;
@end

NS_ASSUME_NONNULL_END
