//
//  SVPProtocolView.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/18.
//

#import "SVPProtocolView.h"
#import "SVPSizeUtils.h"
#import "SVPLocalDataTool.h"

@implementation SVPProtocolView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self svp_setupUI];
    }
    return self;
}

- (void)svp_setupUI {
    self.backgroundColor = [UIColor clearColor];
    UIImageView *bottomBgImageView = [[UIImageView alloc]init];
    bottomBgImageView.frame = CGRectMake(0, 0, [SVPSizeUtils svp_width], [SVPSizeUtils svp_height]);
    bottomBgImageView.image = [UIImage imageNamed:@"purchase_desBgImg"];
    [self addSubview:bottomBgImageView];
    
    UIImageView *textImageView = [[UIImageView alloc]init];
    textImageView.frame = CGRectMake(20, [SVPSizeUtils svp_statusFrameHeight] + 40, [SVPSizeUtils svp_width] - 40, [SVPSizeUtils svp_width] / 1.1);
    textImageView.image = [UIImage imageNamed:@"Launch_protocol_des"];
    [self addSubview:textImageView];
    
    UIButton *svp_UserAcceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
    svp_UserAcceptButton.frame = CGRectMake(0, 0, [SVPSizeUtils svp_width] / 1.5,  55);
    svp_UserAcceptButton.center = CGPointMake([SVPSizeUtils svp_width] / 2,  [SVPSizeUtils svp_height] - 120);
    
    svp_UserAcceptButton.titleLabel.font =  [UIFont fontWithName:@"Helvetica-Bold" size:20.0];;
    [svp_UserAcceptButton setTitleColor:[UIColor colorWithRed:0.00 green:0.60 blue:0.97 alpha:1.00] forState:UIControlStateNormal];
    svp_UserAcceptButton.layer.masksToBounds = YES;
    svp_UserAcceptButton.layer.cornerRadius = 27.5;
    [svp_UserAcceptButton addTarget:self action:@selector(svp_UserAcceptButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [svp_UserAcceptButton setTitle:@"ACCEPT & CLOSE" forState:UIControlStateNormal];
    svp_UserAcceptButton.titleLabel.textColor = [UIColor whiteColor];
    svp_UserAcceptButton.backgroundColor = [UIColor whiteColor];
    [self addSubview:svp_UserAcceptButton];
}

- (void)svp_UserAcceptButtonClick{
    [SVPLocalDataTool setObject:@"9" forKey:@"svp_protocol"];
    if ([self.svp_delegate respondsToSelector:@selector(setupSVPLaunchProtocolViewClick:)]) {
        [self.svp_delegate setupSVPLaunchProtocolViewClick:self];
    }
    [self removeFromSuperview];
}
@end
