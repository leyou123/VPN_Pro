//
//  SVPAdmobBannerView.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/30.
//

#import "SVPAdmobBannerView.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface SVPAdmobBannerView ()<GADBannerViewDelegate>

@end

@implementation SVPAdmobBannerView

- (void)setup_svpAdmobBannerView:(UIViewController *)controller AdUnitID:(NSString *)AdUnitID {
    GADBannerView *bannerView = [[GADBannerView alloc] init];
    bannerView.frame = CGRectMake(0,0, self.frame.size.width, 50);
    bannerView.adUnitID = AdUnitID;
    bannerView.rootViewController = controller;
    bannerView.delegate = self;
    GADRequest *request = [GADRequest request];
    [bannerView loadRequest:request];
    [self addSubview:bannerView];
}

- (void)bannerViewWillPresentScreen:(nonnull GADBannerView *)bannerView {
    
}

- (void)bannerViewWillDismissScreen:(nonnull GADBannerView *)bannerView {
    
}

- (void)bannerViewDidDismissScreen:(nonnull GADBannerView *)bannerView {
    
}
@end
