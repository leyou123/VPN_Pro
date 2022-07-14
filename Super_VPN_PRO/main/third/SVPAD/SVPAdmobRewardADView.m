//
//  SVPAdmobRewardADView.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/30.
//

#import "SVPAdmobRewardADView.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "MBProgressManager.h"
@import UIKit;

@interface SVPAdmobRewardADView ()<GADFullScreenContentDelegate>
@property (nonatomic,strong)GADRewardedAd *rewardedAd;
@end

@implementation SVPAdmobRewardADView

- (void)setup_svpAdmobRewardedAdView:(UIViewController *)controller AdUnitID:(NSString *)adUnitID {
    GADRequest *request = [GADRequest request];
    [GADRewardedAd loadWithAdUnitID:adUnitID
                            request:request
                  completionHandler:^(GADRewardedAd *ad, NSError *error) {
      if (error) {
        NSLog(@"Rewarded ad failed to load with error: %@", [error localizedDescription]);
          [MBProgressManager showBriefAlert:NSLocalizedString(@"AdLoadingFailed", nil) time:3];
          [MBProgressManager hideAlert];
        return;
      }else {
        // Ad successfully loaded.
        [MBProgressManager hideAlert];
        self.rewardedAd = ad;
        NSLog(@"Rewarded ad loaded.");
        self.rewardedAd.fullScreenContentDelegate = self;
        if (self.rewardedAd && [self.rewardedAd canPresentFromRootViewController:controller error:nil]) {
             [self.rewardedAd presentFromRootViewController:controller
                                           userDidEarnRewardHandler:^{
                                         }];
        } else {
             NSLog(@"Ad wasn't ready");
        }
      }
    }];
}

- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    [MBProgressManager showBriefAlert:NSLocalizedString(@"AdLoadingFailed", nil) time:3];
    [MBProgressManager hideAlert];
}

- (void)adDidPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {

}

- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {

}
@end
