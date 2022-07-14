//
//  SVPCustomBannerView.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/30.
//

#import "SVPCustomBannerView.h"
#import "UIImageView+WebCache.h"
#import "SVPDeviceUtils.h"
#import "SVPSizeUtils.h"

@implementation SVPCustomBannerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

- (void)setSvp_BannerTag:(NSString *)svp_BannerTag {
    _svp_BannerTag = svp_BannerTag;
    [self setup_svpUI];
}

- (void)setup_svpUI {
    UIImageView *svp_bannerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - 50, self.frame.size.width, 50)];
    svp_bannerImageView.backgroundColor = [UIColor whiteColor];
    [svp_bannerImageView sd_setImageWithURL:[NSURL URLWithString:self.svp_BannerImageUrl]];
    svp_bannerImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:svp_bannerImageView];
    
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ImageViewTap)];
    [svp_bannerImageView addGestureRecognizer:tapGesture];
    svp_bannerImageView.userInteractionEnabled = YES;
    
    UIButton *svp_closedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    svp_closedButton.frame = CGRectMake(self.frame.size.width - 30,0,30,30);
    svp_closedButton.imageEdgeInsets = UIEdgeInsetsMake(0,5,10,5);
    svp_closedButton.backgroundColor = [UIColor clearColor];
    [svp_closedButton setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
    [svp_closedButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:svp_closedButton];
}

- (void)closeButtonAction:(UIButton *)sender{
     [self removeFromSuperview];
}

- (void)ImageViewTap{
    if (self.svp_BannerUrl.length == 0) {
        if ([self.delegate respondsToSelector:@selector(setup_svpBannerViewClick:)]) {
            [self.delegate setup_svpBannerViewClick:self];
        }
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.svp_BannerUrl] options:@{} completionHandler:nil];
    }
}
@end
