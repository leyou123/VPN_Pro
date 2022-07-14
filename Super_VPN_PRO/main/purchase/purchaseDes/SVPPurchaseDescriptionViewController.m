//
//  SVPPurchaseDescriptionViewController.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/24.
//

#import "SVPPurchaseDescriptionViewController.h"
#import "SVPSizeUtils.h"
#import "SVPLocalDataTool.h"

@interface SVPPurchaseDescriptionViewController ()
@property (nonatomic,strong)UIScrollView *svp_bgScrollView;
@property (nonatomic, strong)UIImageView *topSupLogoImageView;
@property (nonatomic,strong)UILabel *appTitltLabel;
@property (nonatomic,strong)UILabel *contentLabel;
@property (nonatomic,strong)UILabel *productDetailsLabel;
@property (nonatomic,strong)UIButton *freeTrialButton;
@end

@implementation SVPPurchaseDescriptionViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    [self setup_svpDesUI];
}

- (void)setup_svpDesUI {
    UIImageView *purchaseDesBgImageView = [[UIImageView alloc]init];
    purchaseDesBgImageView.frame = CGRectMake(0, 0, [SVPSizeUtils svp_width], [SVPSizeUtils svp_height]);
    purchaseDesBgImageView.image = [UIImage imageNamed:@"purchase_desBgImg"];
    [self.view addSubview:purchaseDesBgImageView];
    
    self.svp_bgScrollView = [[UIScrollView alloc]init];
    self.svp_bgScrollView.frame = CGRectMake(0, 0, [SVPSizeUtils svp_width], [SVPSizeUtils svp_height]);
    self.svp_bgScrollView.alwaysBounceHorizontal = NO;
    self.svp_bgScrollView.backgroundColor = [UIColor clearColor];
    self.svp_bgScrollView.contentSize = CGSizeMake([SVPSizeUtils svp_width],[SVPSizeUtils svp_height] + [SVPSizeUtils svp_width] /1.5);
    [self.view addSubview:self.svp_bgScrollView];
    
    self.appTitltLabel = [[UILabel alloc]init];
    self.appTitltLabel.frame = CGRectMake(0, 55, [SVPSizeUtils svp_width] - 30, 30);
    self.appTitltLabel.text = NSLocalizedString(@"TitleName", nil);
    self.appTitltLabel.textAlignment = NSTextAlignmentCenter;
    [self.appTitltLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:22.5f]];
    self.appTitltLabel.textColor = [UIColor whiteColor];
    [self.svp_bgScrollView addSubview:self.appTitltLabel];
    
    
    self.productDetailsLabel = [[UILabel alloc]init];
    self.productDetailsLabel.frame = CGRectMake(20, self.appTitltLabel.frame.origin.y + 10, [SVPSizeUtils svp_width]- 45, [SVPSizeUtils svp_width] / 1.1);
    self.productDetailsLabel.text = @"This enables a 3 days free trial,followed by a subscription to Polar China Premium for different varieties : \n$2.99 for 30 days,\n$8.99 for 90 days,\n$18.99 for 180 days and $38.99 for 360 days.\nBy joining you accept our Terms of Use,Privacy Policy and Subscription Policy.This subscription auto-renews based on your VIP variety you chosed at the end of each term unless cancelled 24 hours in advance. The subscription fee is charged to your iTunes account at confirmation of purchase.You may manage your subscription and turn off auto-renewal by going to your Settings.No cancellation of the current subscription is allowed during active period.Any unused portion of a free trial period, if offered, will be forfeited when the user purchases a subscription to that publication, where applicable.";
    self.productDetailsLabel.textAlignment = NSTextAlignmentLeft;
    self.productDetailsLabel.numberOfLines = 0;
    self.productDetailsLabel.font = [UIFont systemFontOfSize:13.0f];
    self.productDetailsLabel.textColor = [UIColor whiteColor];
    self.productDetailsLabel.backgroundColor = [UIColor clearColor];
    [self.svp_bgScrollView addSubview:self.productDetailsLabel];
    
    NSArray *privacyArr = @[NSLocalizedString(@"TermsOfService", nil),NSLocalizedString(@"PrivacyPolicy", nil),@""];
    
    NSInteger privacyTag = 1100;
    for (int i = 0; i < 3; i ++) {
        UIButton *privacyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        privacyButton.frame = CGRectMake(0 + [SVPSizeUtils svp_width] / 2 *i,self.productDetailsLabel.frame.origin.y + self.productDetailsLabel.frame.size.height+2, [SVPSizeUtils svp_width] / 2, 40);
        privacyButton.titleLabel.font = [UIFont systemFontOfSize: 14.5f];
        privacyButton.tag = privacyTag++;
        [privacyButton addTarget:self action:@selector(privacyButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [privacyButton setTitle:[privacyArr objectAtIndex:i] forState:UIControlStateNormal];
        privacyButton.titleLabel.textColor = [UIColor whiteColor];
        privacyButton.backgroundColor = [UIColor clearColor];
        [self.svp_bgScrollView addSubview:privacyButton];
        
        self.freeTrialButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.freeTrialButton.frame = CGRectMake(0, 0, [SVPSizeUtils svp_width] / 1.8, 50);
        self.freeTrialButton.center = CGPointMake([SVPSizeUtils svp_width]/2, [SVPSizeUtils svp_height] - 95);
        [self.freeTrialButton addTarget:self action:@selector(freeTrialButtonClick) forControlEvents:UIControlEventTouchUpInside];
        self.freeTrialButton.backgroundColor = [UIColor colorWithRed:24.0/255.0 green:189.0/255.20 blue:241.0/255.0 alpha:1];
        [self.freeTrialButton setTitle:NSLocalizedString(@"SVP_Trial", nil) forState:UIControlStateNormal];
        self.freeTrialButton.titleLabel.font = [UIFont systemFontOfSize: 15.0];
        self.freeTrialButton.layer.cornerRadius = 10;
        self.freeTrialButton.layer. masksToBounds = YES;
        [self.view addSubview:self.freeTrialButton];
    }
}


- (void)privacyButtonClick:(UIButton *)sender{
    switch (sender.tag) {
        case 1100: {
            NSString *svp_serviceURL = [SVPLocalDataTool objectForKey:@"service_url"];
            if ([svp_serviceURL isEqualToString:@""]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",@"https://demo.hedgedoc.org/s/n61X0SXtY"]] options:@{} completionHandler:nil];
            }else{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:svp_serviceURL] options:@{} completionHandler:nil];
            }
        }
            break;
        case 1101:  {
            NSString *svp_privacyURL = [SVPLocalDataTool objectForKey:@"privacy_url"];
            if ([svp_privacyURL isEqualToString:@""]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",@"https://demo.hedgedoc.org/s/3LzKs11H3"]] options:@{} completionHandler:nil];
            }else{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:svp_privacyURL] options:@{} completionHandler:nil];
            }
        }
            break;
        default:
            break;
    }
}

- (void)freeTrialButtonClick{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
