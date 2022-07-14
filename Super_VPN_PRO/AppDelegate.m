//
//  AppDelegate.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/7.
//

#import "AppDelegate.h"
#import "SVPMainViewController.h"
#import "SVPStoreViewController.h"
#import "SVPSettingsViewController.h"
#import "SVPInterfaceManager.h"
#import "SVPNetworkCheckManager.h"
#import "MBProgressManager.h"
#import <VungleSDK/VungleSDK.h>
#import <JPUSHService.h>
#import "SVPNoneViewController.h"
#import "SVPNetworkCilent.h"
#import "SVPLocalDataTool.h"
#import "SVPDeviceUtils.h"
#import "SVPKeyChainStore.h"
#import "SVPDateUtils.h"
#import <UserNotifications/UserNotifications.h>
#define JPushServiceKey @"6d06f300fffeef622e29b6a5"

@interface AppDelegate ()<JPUSHRegisterDelegate,VungleSDKDelegate>
@property (strong, nonatomic)NSTimer *checkNetworkTimer;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if ([SVPNetworkCheckManager checkSVPNetworkConnection]) {
        [self svpNetworkAvailable];
    }else {
        self.checkNetworkTimer = [NSTimer timerWithTimeInterval:2.5 target:self selector:@selector(checkNetworkTimerRun) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.checkNetworkTimer forMode:NSDefaultRunLoopMode];
    }
    
    JPUSHRegisterEntity *entity = [[JPUSHRegisterEntity alloc]init];
    if (@available(iOS 12.0, *)) {
        entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound|JPAuthorizationOptionProvidesAppNotificationSettings;
    } else {
        // Fallback on earlier versions
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    [JPUSHService setupWithOption:launchOptions appKey:JPushServiceKey channel:@"App Store" apsForProduction:1 advertisingIdentifier:nil];
    //注册远端消息通知获取device token
    [application registerForRemoteNotifications];
    
    [self userLoginSetUp];
    
    [self setStartTime];
    
    return YES;
}

- (void)setStartTime {
    NSString * minute = [[NSUserDefaults standardUserDefaults] objectForKey:@"REMAINMINS"];
    if (minute >= 0) {
    }else {
        [SVPDateUtils setRemainMinute:48*60];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSString * svp_adString = [SVPDeviceUtils getIDFA];
    NSLog(@"ad_idfa :%@", svp_adString);
}

- (void)svpNetworkAvailable {
    
    [self setupSVPAuthorizationService];
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if(resCode == 0){
            NSLog(@"svp_registrationID获取成功：%@",registrationID);
            [SVPLocalDataTool setObject:registrationID forKey:@"registrationID"];

        }else{
            NSLog(@"svp_registrationID获取失败，code：%d",resCode);
        }
    }];
}

- (void)userLoginSetUp {
    [SVPKeyChainStore deleteKeyData:[[NSBundle mainBundle] bundleIdentifier]];
    NSString*strUUID = (NSString*)[SVPKeyChainStore load:[[NSBundle mainBundle] bundleIdentifier]];
    if ([strUUID isEqualToString:@""] || !strUUID) {
        NSString * userId = [[[SVPKeyChainStore getUUIDByKeyChain] stringByReplacingOccurrencesOfString:@"-" withString:@""] substringWithRange:NSMakeRange(7, 16)];
        NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:userId forKey:@"SVP_USERID"];
        [SVPDateUtils saveExpireWithInterval:24*60];
        [userDefault synchronize];
    }
}


- (void)setupSVPAuthorizationService {
    NSString *svp_sandboxString = [NSString stringWithFormat:@"%i",[SVPDeviceUtils isSandboxEnvironment]];
    NSString *svp_serverConnected_status = [NSString stringWithFormat:@"%i",[SVPDeviceUtils isVPNConnected]];
    NSString *svp_proxySetString = [NSString stringWithFormat:@"%i",[SVPDeviceUtils isProxySet]];
    if ([svp_serverConnected_status isEqualToString:@"0"] && [svp_proxySetString isEqualToString:@"0"]) {
//        [SVPNetworkCilent svp_setupAuthorization:svp_sandboxString SVPServerConnected:svp_serverConnected_status proxySet:svp_proxySetString Result:^{
//            [self setupSVPActivationInfomation];
//                } failure:^{
//                    [MBProgressManager showPermanentAlert:@"Authorization verification failed"];
//                }];
        [self setupSVPActivationInfomation];
        [SVPLocalDataTool setObject:@"1" forKey:@"Close"];
    }else {
        if ([[SVPDeviceUtils svp_getAuthorization] isEqualToString:@"(null)"]) {
            [SVPLocalDataTool setObject:@"0" forKey:@"Close"];
        }else{
            [SVPLocalDataTool setObject:@"1" forKey:@"Close"];
        }
        [self setupSVPActivationInfomation];
    }
}

//active
- (void)setupSVPActivationInfomation {
    NSString *svp_userIDString = [SVPDeviceUtils getKeychainSavedString];
    if (svp_userIDString.length == 0) {
        [self svp_firstLaunchScene];
        [SVPLocalDataTool setObject:[SVPDeviceUtils getTimeStamp] forKey:@"timing"];
        [SVPLocalDataTool setObject:[SVPDeviceUtils getTimeStamp] forKey:@"logTraffic"];
    }else {
        [SVPNetworkCilent svp_setupLaunchLog];
        [SVPNetworkCilent svp_setupLaunchLogTimes];
        [self setupSVPTabBarViewController];
    }
}



- (void)svp_firstLaunchScene {
    [SVPNetworkCilent svp_firstLaunchAppStatus:^{
        [SVPNetworkCilent svp_setupLaunchLog];
        [SVPNetworkCilent svp_setupLaunchLogTimes];
        } failure:^{
            NSLog(@"first launch error");
          
        }];
    [self setupSVPTabBarViewController];
}



- (void)checkNetworkTimerRun {
    if ([SVPNetworkCheckManager checkSVPNetworkConnection]) {
        [self.checkNetworkTimer invalidate];
        [self svpNetworkAvailable];
    }else{
        self.window = [[UIWindow alloc]init];
        SVPNoneViewController *noneVC = [[SVPNoneViewController alloc]init];
        self.window.rootViewController = noneVC;
        [self.window makeKeyAndVisible];
//        [MBProgressManager showWaitingWithTitle:NSLocalizedString(@"PleaseCheckYourNetwork", nil)];
    }
}

- (void)dealloc {
    [self.checkNetworkTimer invalidate];
    NSLog(@"%s", __func__);
}

- (void)setupSVPTabBarViewController {
    self.window = [[UIWindow alloc]init];
    self.window.backgroundColor = [UIColor whiteColor];
    UITabBarController *tabBarController = [[UITabBarController alloc]init];
    tabBarController.tabBar.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = tabBarController;
    SVPMainViewController *mainVC = [[SVPMainViewController alloc]init];
    UINavigationController *mainNav = [[UINavigationController alloc]initWithRootViewController:mainVC];
    UIImage *mainNormal = [UIImage imageNamed:@"main_normal"];
    UIImage *mainSelected= [UIImage imageNamed:@"main_selected"];
    mainNav.tabBarItem.image=[mainNormal imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    mainNav.tabBarItem.selectedImage = [mainSelected imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
    SVPStoreViewController *storeVC = [[SVPStoreViewController alloc]init];
    UINavigationController *storeNav=[[UINavigationController alloc]initWithRootViewController:storeVC];
    UIImage *storeNormal = [UIImage imageNamed:@"purchase_normal"];
    UIImage *storeSelected= [UIImage imageNamed:@"purchase_selected"];
    storeNav.tabBarItem.image=[storeNormal imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    storeNav.tabBarItem.selectedImage = [storeSelected imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
    SVPSettingsViewController *settingVC = [[SVPSettingsViewController alloc]init];
    UINavigationController *settingNav=[[UINavigationController alloc]initWithRootViewController:settingVC];
    UIImage *settingNormal = [UIImage imageNamed:@"setting_normal"];
    UIImage *settingSelected= [UIImage imageNamed:@"setting_selected"];
    settingNav.tabBarItem.image=[settingNormal imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    settingNav.tabBarItem.selectedImage = [settingSelected imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
     
    tabBarController.viewControllers=@[mainNav,storeNav,settingNav];
    tabBarController.selectedIndex = 0;
    
    if (@available(iOS 13.0, *)) {
        self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    } else {
    }
    [self.window makeKeyAndVisible];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken {
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [SVPNetworkCilent svp_setupLaunchLogTimes];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}


- (void)jpushNotificationAuthorization:(JPAuthorizationStatus)status withInfo:(NSDictionary *)info {
}

- (void)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo
          fetchCompletionHandler:
              (void (^)(UIBackgroundFetchResult))completionHandler {
  [JPUSHService handleRemoteNotification:userInfo];
  if ([[UIDevice currentDevice].systemVersion floatValue]<10.0 || application.applicationState>0) {
  }

  completionHandler(UIBackgroundFetchResultNewData);
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
      [JPUSHService handleRemoteNotification:userInfo];

    }else {
      // 判断为本地通知
      NSLog(@"iOS10 收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    completionHandler();  // 系统要求执行这个方法
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    NSDictionary * userInfo = notification.request.content.userInfo;
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
      [JPUSHService handleRemoteNotification:userInfo];
    }else {
      // 判断为本地通知
      NSLog(@"iOS10 前台收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
}

@end
