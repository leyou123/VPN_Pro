//
//  SVPVungleInterstitialView.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/30.
//

#import "SVPVungleInterstitialView.h"
#import <VungleSDK/VungleSDK.h>

@interface SVPVungleInterstitialView ()<VungleSDKDelegate>
@property (nonatomic,strong)VungleSDK* vungleSDK;
@property (nonatomic,strong)UIViewController *controller;

@end

@implementation SVPVungleInterstitialView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    };
  
    return self;
}

- (void)setup_svpVungleInterstitialView:(UIViewController *)controller ProjectKey:(NSString *)projectKey {
    NSError* error;
    self.vungleSDK = [VungleSDK sharedSDK];
    [self.vungleSDK setDelegate:self];
    [self.vungleSDK setLoggingEnabled:YES];
    [self.vungleSDK startWithAppId:projectKey error:&error];
}
- (void)vungleSDKDidInitialize{
    NSError* error;
    [self.vungleSDK loadPlacementWithID:self.svp_unit_key error:&error];
}

- (void)vungleSDKFailedToInitializeWithError:(NSError *)error{
}
    
- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable placementID:(nullable NSString *)placementID error:(nullable NSError *)error{
    if (isAdPlayable) {
         if([self.vungleSDK isAdCachedForPlacementID:self.svp_unit_key]){
             NSError* error;
             [self.vungleSDK playAd:self.controller options:nil placementID:self.svp_unit_key error:&error];
             if (error) {
                 NSLog(@"Error encountered playing ad: %@", error);
             }
         }
    } else {
    }
}

- (void)vungleWillShowAdForPlacementID:(nullable NSString *)placementID{

}

- (void)vungleWillCloseAdForPlacementID:(nonnull NSString *)placementID {
}

- (void)vungleDidCloseAdForPlacementID:(nonnull NSString *)placementID {

}
@end
