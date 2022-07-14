//
//  SVPCustomInterstitalView.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/30.
//

#import "SVPCustomInterstitalView.h"
#import "UIImageView+WebCache.h"
#import "SVPPurchaseDescriptionViewController.h"

@implementation SVPCustomInterstitalView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

- (void)setSvp_InterstitialTag:(NSString *)svp_InterstitialTag {
    _svp_InterstitialTag = svp_InterstitialTag;
    [self setup_svpInterstitalViewUI];
}

- (void)setup_svpInterstitalViewUI {
    UIImageView *svp_InterstitialImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [svp_InterstitialImageView sd_setImageWithURL:[NSURL URLWithString:self.svp_InterstitialImageUrl]];
    svp_InterstitialImageView.backgroundColor = [UIColor blackColor];
    [self addSubview:svp_InterstitialImageView];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ImageTap)];
    [svp_InterstitialImageView addGestureRecognizer:tapGesture];
    svp_InterstitialImageView.userInteractionEnabled = YES;
    
    
    UIButton *svp_ClosedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    svp_ClosedButton.frame = CGRectMake(10,30,50,50);
    svp_ClosedButton.imageEdgeInsets = UIEdgeInsetsMake(13,13,13,13);
    svp_ClosedButton.backgroundColor = [UIColor clearColor];
    [svp_ClosedButton setImage:[UIImage imageNamed:@"banner_close"] forState:UIControlStateNormal];
    [svp_ClosedButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:svp_ClosedButton];
}

- (void)ImageTap{
    if (self.svp_InterstitialUrl.length == 0) {
        [self removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(setup_svpInterstitialViewClick:)]) {
            [self.delegate setup_svpInterstitialViewClick:self];
        }
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.svp_InterstitialUrl] options:@{} completionHandler:nil];
    }
}

- (void)closeAction:(UIButton *)sender{
    [self removeFromSuperview];
}
@end
