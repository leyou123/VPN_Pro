//
//  SVPVungleBannerView.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/30.
//

#import "SVPVungleBannerView.h"
#import <VungleSDK/VungleSDK.h>

@interface SVPVungleBannerView ()<VungleSDKDelegate>
@property (nonatomic,strong)VungleSDK* vungleSDK;
@property (nonatomic,strong)UIViewController *controller;
@property (retain, nonatomic)UIView *svp_bannerView;
@end

@implementation SVPVungleBannerView

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    return self;
}

- (void)setup_svpVungleBannerView:(UIViewController *)controller ProjectKey:(NSString *)projectKey {
    NSError* error;
    self.vungleSDK = [VungleSDK sharedSDK];
    [self.vungleSDK setDelegate:self];
    [self.vungleSDK setLoggingEnabled:YES];
    [self.vungleSDK startWithAppId:projectKey error:&error];
}

- (void)vungleSDKDidInitialize{
    NSError* error;
    [self.vungleSDK loadPlacementWithID:self.svp_unit_key withSize:VungleAdSizeBannerShort error:&error];
}

- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable placementID:(nullable NSString *)placementID error:(nullable NSError *)error{
    // 缓存广告成功或失败
    NSLog(@"======-----%i ==== %@",isAdPlayable,error);
    if (isAdPlayable) {
        NSLog(@"-->> Delegate Callback: vungleAdPlayabilityUpdate: Ad is available for Placement ID: %@", placementID);
            NSError* error;
            [self.vungleSDK addAdViewToView:self withOptions:nil placementID:self.svp_unit_key error:&error];
            if (error) {
                NSLog(@"Error encountered playing ad: %@", error);
            }
    } else {
        NSLog(@"-->> Delegate Callback: vungleAdPlayabilityUpdate: Ad is NOT available for Placement ID: %@", placementID);
    }
}

- (void)vungleWillShowAdForPlacementID:(nullable NSString *)placementID{

}
@end
