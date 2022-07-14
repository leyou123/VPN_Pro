//
//  SVPAdmobInterstitialView.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/30.
//

#import "SVPAdmobInterstitialView.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface SVPAdmobInterstitialView ()<GADFullScreenContentDelegate>
@property (nonatomic,strong)GADInterstitialAd *svp_Interstitial;

@end

@implementation SVPAdmobInterstitialView

- (void)setup_svpAdmobInterstitialView:(UIViewController *)controller AdUnitID:(NSString *)AdUnitID {
    GADRequest *request = [GADRequest request];
     [GADInterstitialAd loadWithAdUnitID:AdUnitID
                                 request:request
                       completionHandler:^(GADInterstitialAd *ad, NSError *error) {
       if (error) {
         NSLog(@"Failed to load interstitial ad with error: %@", [error localizedDescription]);
         return;
       }
       self.svp_Interstitial = ad;
       self.svp_Interstitial.fullScreenContentDelegate = self;
     }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.svp_Interstitial presentFromRootViewController:controller];
    });
}

- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    
}

/// Tells the delegate that the ad presented full screen content.
- (void)adDidPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    
}

/// Tells the delegate that the ad will dismiss full screen content.
- (void)adWillDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    
}

@end
