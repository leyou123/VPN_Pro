//
//  SVPMainViewController.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/8.
//

#import "SVPMainViewController.h"
#import "SVPModeViewController.h"
#import "SVPLinesViewController.h"

#import "SVPNServerManager.h"
//#import "SVPServerManager.h"
#import "SVPServerConnection.h"
#import "SVPConnector.h"
#import <NetworkExtension/NetworkExtension.h>

#import "SVPProtocolView.h"
#import "SVPMainInfoModel.h"

#import "MBProgressManager.h"
#import "SVPInterfaceManager.h"
#import "SVPNetworkCilent.h"
#import "SVPLocalDataTool.h"
#import "SVPSizeUtils.h"
#import "SVPDeviceUtils.h"
#import "MarqueeLabel.h"
#import "SVPDes.h"

#import "SVPVungleInterstitialView.h"
#import "SVPVungleBannerView.h"
#import "SVPCustomBannerView.h"
#import "SVPCustomInterstitalView.h"
#import "SVPAdmobBannerView.h"
#import "SVPAdmobInterstitialView.h"
#import "SVPAdmobRewardADView.h"

#include <arpa/inet.h>
#include <ifaddrs.h>
#include <netdb.h>
#include <sys/socket.h>
#import <PacketProcessor_iOS/TunnelInterface.h>

@interface SVPMainViewController ()<SVProtocolViewDelegate,SVPServerConnectorDelegate,SVPLinesViewControllerDelegate,SVPCustomInterstitalViewDelegate,CustomBannerViewDelegate>

@property (strong, nonatomic)SVPServerConnection *svp_connection;
@property (strong, nonatomic)SVPConnector *svp_connector;
@property (strong, nonatomic)SVPSeverInfo *svp_serverInfo;

@property (strong, nonatomic)SVPMainInfoModel *svp_mainModel;
@property (strong, nonatomic)UIImageView *svp_animatedImageView;
@property (strong, nonatomic)MarqueeLabel *svp_messageLabel;
@property (strong, nonatomic)UIButton *svp_connectButton;
@property (strong, nonatomic)UILabel *svp_connectStatusLabel;
@property (strong, nonatomic)UILabel *svp_protocolLabel;
@property (strong, nonatomic)UILabel *svp_linesLabel;
@property (strong, nonatomic)NSString *svp_isVIPString;
@property (strong, nonatomic)NSMutableArray *svp_linesArray;

@property (nonatomic,strong)NSString *svp_serverID;
@property (strong, nonatomic)NSString *svp_is_trail;
@property (strong, nonatomic)NSString *svp_allow_trial_traffic;
@property (assign, nonatomic)NSInteger svp_trial_traffic;
@property (strong, nonatomic)NSString *svp_allow_trial_time;
@property (strong, nonatomic)NSString *svp_expired_at;
@property (strong, nonatomic)NSString *svp_current_time;
@property (strong, nonatomic)NSString *svp_lines_select_type;


@end

@implementation SVPMainViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    if ([[SVPDeviceUtils svp_getIsBlock]isEqualToString:[SVPDeviceUtils svp_getIsBlockStatus]]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"IsBlock", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    [self setupSVP_ModeProtocol];
    [self setup_svpCheckVIPLimitStatus];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"main_topBg"] forBarMetrics:UIBarMetricsDefault];
    self.view.backgroundColor = [UIColor whiteColor];
    self.svp_linesArray = [[NSMutableArray alloc]init];
    [self setupUserLaunchProtocol];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(svp_comeBack)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)setupUserLaunchProtocol {
    NSString *svp_protocolString = [SVPLocalDataTool objectForKey:@"svp_protocol"];
    SVPProtocolView *svp_protocolView = [[SVPProtocolView alloc]init];
    if (svp_protocolString == nil) {
        svp_protocolView.frame = CGRectMake(0, 0, [SVPSizeUtils svp_width], [SVPSizeUtils svp_height]);
        svp_protocolView.svp_delegate = self;
        [[UIApplication sharedApplication].keyWindow addSubview:svp_protocolView];
    }else {
        [svp_protocolView removeFromSuperview];
        [self setup_svpUsersLaunchAfterProtocol];
    }
}

#pragma mark - Protocol Delegate
- (void)setupSVPLaunchProtocolViewClick:(SVPProtocolView *)svp_protocol {
    [self setup_svpUsersLaunchAfterProtocol];
}

#pragma mark - Methods
- (void)setup_svpUsersLaunchAfterProtocol {
    [self setupSVPMainUI];
    [self setupSVP_AppInfo];
    [self setupSVP_ScrollMessageData];
    
}

- (void)setup_svpCheckVIPLimitStatus {
    NSString *svp_pathString = @"/v1/account/limit";
    [SVPInterfaceManager svp_post:svp_pathString withParams:nil success:^(id  _Nullable response) {
        NSDictionary *resultDic = (NSDictionary*)response;
        NSString *svp_resultString = [SVPDes decode:[resultDic objectForKey:@"data"] key:[SVPDeviceUtils getDesKeyString]];
        NSDictionary *svp_dic = [SVPDeviceUtils dictionaryWithJsonString:svp_resultString];
        self.svp_isVIPString = [svp_dic objectForKey:@"is_vip"];
        self.svp_is_trail = [svp_dic objectForKey:@"is_trial"];
        if ([self.svp_isVIPString integerValue] == 0 && [self.svp_is_trail integerValue] == 1) {
            self.svp_allow_trial_traffic = [svp_dic objectForKey:@"allow_trial_traffic"];
            self.svp_trial_traffic = [[svp_dic objectForKey:@"trial_traffic"] integerValue]*(1024*1024);
            self.svp_allow_trial_time = [svp_dic objectForKey:@"allow_trial_time"];
            self.svp_expired_at = [svp_dic objectForKey:@"expired_at"];
            self.svp_current_time = [svp_dic objectForKey:@"current_time"];

            if ([self.svp_allow_trial_traffic integerValue] == 1) {
                [self setup_svpTrafficTrialSetting:[self.svp_isVIPString integerValue]];
            }
            if ([self.svp_allow_trial_time integerValue] == 1) {
                [self setup_svpTimeTrialSetting:[self.svp_isVIPString integerValue]];
            }
        }else if([self.svp_isVIPString integerValue] == 1){
            [SVPLocalDataTool setObject:@"1" forKey:@"noTraffic"];
//            [[SVPServerManager shared]svp_setDataFlowLimit:-1 completion:^(NSDictionary * _Nonnull response) {
//                NSLog(@"--------------%@",response);
//            }];
        }else if ([self.svp_isVIPString integerValue] == 0 && [self.svp_is_trail integerValue] == 0){
            if (self.svp_connectButton.selected == YES) {
                [self svp_serverStopDisconnect:NO];
            }
            [SVPLocalDataTool setObject:@"0" forKey:@"noTraffic"];
           }
        } failure:^(NSError * _Nonnull error, id  _Nullable response) {
//            [MBProgressManager showBriefAlert:NSLocalizedString(@"SVP_Anomaly", nil) time:3];
        }];
}

- (void)setup_svpTrafficTrialSetting:(NSInteger)svp_vipType {
    NSString *svp_userIDString = [SVPDeviceUtils getKeychainSavedString];
    if (svp_userIDString.length == 0) {
        [SVPLocalDataTool setObject:@"1" forKey:@"noTraffic"];
    }else {
        if (svp_vipType == 0 && [self.svp_allow_trial_traffic integerValue] == 1) {
//            [[SVPServerManager shared]svp_getTotalDataFlow:^(long totalBytes) {
//                if ((totalBytes/1024/1024) < (self.svp_trial_traffic/1024/1024)) {
//                    [[SVPServerManager shared]svp_setDataFlowLimit:self.svp_trial_traffic completion:^(NSDictionary * _Nonnull response) {
//                    }];
//                    [SVPLocalDataTool setObject:@"1" forKey:@"noTraffic"];
//                }else {
//                    if (self.svp_connectButton.selected == YES) {
//                        [self svp_serverStopDisconnect:NO];
//                    }
//                    [SVPNetworkCilent svp_setupTrailDisable];
//                    [SVPLocalDataTool setObject:@"0" forKey:@"noTraffic"];
//                }
//            }];
        }else if (svp_vipType == 1){
            [SVPLocalDataTool setObject:@"1" forKey:@"noTraffic"];
        }else if ([self.svp_allow_trial_traffic integerValue] == 0){
            [SVPLocalDataTool setObject:@"0" forKey:@"noTraffic"];
            if ([self.svp_allow_trial_time integerValue] == 1) {
                if ([self.svp_current_time integerValue] < [self.svp_expired_at integerValue]) {
                    [SVPLocalDataTool setObject:@"1" forKey:@"noTraffic"];
                }else {
                    if (self.svp_connectButton.selected == YES) {
                        [self svp_serverStopDisconnect:NO];
                    }
                    [SVPLocalDataTool setObject:@"0" forKey:@"noTraffic"];
                }
            }
        }
    }
}

- (void)setup_svpTimeTrialSetting:(NSInteger)svp_vipType {
    if (svp_vipType == 0 && [self.svp_allow_trial_time integerValue] == 1) {
        if ([self.svp_current_time integerValue] < [self.svp_expired_at integerValue]) {
            [SVPLocalDataTool setObject:@"1" forKey:@"noTraffic"];
        }else {
            [SVPLocalDataTool setObject:@"0" forKey:@"noTraffic"];
        }
    }else if (svp_vipType ==1){
        [SVPLocalDataTool setObject:@"1" forKey:@"noTraffic"];
    }else if ([self.svp_allow_trial_time integerValue] == 0){
        [SVPLocalDataTool setObject:@"0" forKey:@"noTraffic"];
        if ([self.svp_allow_trial_traffic integerValue] == 1) {
//            [[SVPServerManager shared]svp_getTotalDataFlow:^(long totalBytes) {
//                if ((totalBytes/1024/1024)<(self.svp_trial_traffic/1024/1024)) {
//                    [SVPLocalDataTool setObject:@"1" forKey:@"noTraffic"];
//                }else {
//                    [SVPLocalDataTool setObject:@"0" forKey:@"noTraffic"];
//                    [SVPNetworkCilent svp_setupTrailDisable];
//                    if (self.svp_connectButton.selected == YES) {
//                        [self svp_serverStopDisconnect:NO];
//                    }
//                }
//            }];
        }
    }
}

- (void)setupSVP_AppInfo {
    [SVPNetworkCilent svp_setupAppInitlizationInfoSuccess:^(SVPMainInfoModel * _Nonnull svp_model) {
        self.svp_mainModel = svp_model;
        [SVPLocalDataTool setObject:svp_model.svp_service_mail forKey:@"serviceMail"];
        [SVPLocalDataTool setObject:svp_model.svp_is_blockString forKey:@"is_block"];
        [SVPLocalDataTool setObject:svp_model.svp_server_delay_type forKey:@"server_delay_type"];
        if (svp_model.svp_Speed_TestDic!= nil) {
            [SVPNetworkCilent svp_setupSpeedPath:[svp_model.svp_Speed_TestDic objectForKey:@"path"]];
        }
//        if ([svp_model.svp_task_switch integerValue]!=0) {
//            [self setup_svpTask];
//        }
        self.svp_lines_select_type = svp_model.svp_server_select_type;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setup_svpLineForVIPService:self.svp_isVIPString];
        });
        [self setup_svpADInfo];
        [SVPLocalDataTool setObject:svp_model.svp_service_url forKey:@"service_url"];
        [SVPLocalDataTool setObject:svp_model.svp_privacy_url forKey:@"privacy_url"];
        
        [self setup_svpAppleOrderCheckWith:svp_model.svp_purchase_verify_time];
        [self setup_svpCurrentUsedTraffic:svp_model.svp_traffic_update_time];
        
        [SVPLocalDataTool setObject:svp_model.svp_update_url forKey:@"ForceUrl"];
//        if ([svp_model.svp_notice_switch integerValue] == 1 && [svp_model.svp_update_switch integerValue] == 1 && [svp_model.svp_update_url_switch integerValue] == 1) {
//            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Tips", nil) message:NSLocalizedString(@"ForcedUpdate", nil) preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//            }];
//            [alert addAction:defaultAction];
//            [self presentViewController:alert animated:YES completion:nil];
//        }
        
        } fail:^(NSError * _Nonnull error, id  _Nullable response) {
            [MBProgressManager showBriefAlert:@"request server fail" time:3];
        }];
}

- (void)setup_svpLineForVIPService:(NSString *)svp_isVIPString {
    NSString *svp_pathString = @"/v1/area";
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"0" forKey:@"is_vip"];
    [SVPInterfaceManager svp_post:svp_pathString withParams:dic success:^(id  _Nullable response) {
        NSString *svp_responseString = [response objectForKey:@"data"];
        NSString *svp_resultString = [SVPDes decode:svp_responseString key:[SVPDeviceUtils getDesKeyString]];
        self.svp_linesArray = [SVPDeviceUtils arrayWithJsonString:svp_resultString];
        
        [self setup_svpRandomLines:svp_isVIPString];
        [self svp_setupConnectionConfiguration];
        [self setup_svpConnectionStatus];
        } failure:^(NSError * _Nonnull error, id  _Nullable response) {
            NSLog(@"LineForVIPService error:%@",error);
        }];
}

- (void)setup_svpRandomLines:(NSString *)svp_vipType {
    if ([self.svp_lines_select_type integerValue] == 1) {
        int index = arc4random()% self.svp_linesArray.count;
        if ([[self.svp_linesArray objectAtIndex:index]objectForKey:@"line"]!= nil) {
            NSData *svp_data = [NSKeyedArchiver archivedDataWithRootObject:[[self.svp_linesArray objectAtIndex:index]objectForKey:@"line"]];
            [SVPLocalDataTool setObject:svp_data forKey:@"ConfigurationV"];
            [SVPLocalDataTool setObject:[[self.svp_linesArray objectAtIndex:index]objectForKey:@"status"] forKey:@"lineStatus"];
            [SVPLocalDataTool setObject:[[self.svp_linesArray objectAtIndex:index]objectForKey:@"name"] forKey:@"lineName"];
            self.svp_linesLabel.text = [[self.svp_linesArray objectAtIndex:index]objectForKey:@"name"];
        }else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self setup_svpRandomLines:svp_vipType];
            });
        }
    }else {
        NSData *svp_linesData = [SVPLocalDataTool objectForKey:@"ConfigurationV"];
        NSDictionary *svp_linesDic = [NSKeyedUnarchiver unarchiveObjectWithData:svp_linesData];
        if (svp_linesDic == nil) {
            [self setup_svpNotRandomLines:svp_vipType];
        }else{
            [self setup_svpLinesCompareCheck:[svp_linesDic objectForKey:@"ip"] svp_VIPType:svp_vipType];
        }
    }
}

- (void)setup_svpNotRandomLines:(NSString *)svp_vipType {
    if ([[self.svp_linesArray objectAtIndex:0]objectForKey:@"line"]!= nil){
        NSData *svp_linesData = [NSKeyedArchiver archivedDataWithRootObject:[[self.svp_linesArray objectAtIndex:0]objectForKey:@"line"]];
        [SVPLocalDataTool setObject:svp_linesData forKey:@"ConfigurationV"];
        [SVPLocalDataTool setObject:[[self.svp_linesArray objectAtIndex:0]objectForKey:@"status"] forKey:@"lineStatus"];
        if ([svp_vipType integerValue] == 0) {
            [SVPLocalDataTool setObject:[[self.svp_linesArray objectAtIndex:0]objectForKey:@"ping_subnet"] forKey:@"pingSubnetFree"];
        }else{
            [SVPLocalDataTool setObject:[[self.svp_linesArray objectAtIndex:0]objectForKey:@"ping_subnet"] forKey:@"pingSubnetVIP"];
        }
        [SVPLocalDataTool setObject:[[self.svp_linesArray objectAtIndex:0]objectForKey:@"name"] forKey:@"lineName"];
        self.svp_linesLabel.text = [[self.svp_linesArray objectAtIndex:0]objectForKey:@"name"];
    }else {
        [MBProgressManager showBriefAlert:NSLocalizedString(@"ManualTips", nil) time:2];
    }
    [self setup_svpIKevMode];
}

- (void)setup_svpLinesCompareCheck:(NSString *)svp_lineIPString svp_VIPType:(NSString *)type {
    [SVPNetworkCilent svp_setupLinesCheckService:svp_lineIPString VIPType:type Status:^{
        } failure:^{
            [self setup_svpNotRandomLines:type];
        }];
}

- (void)setup_svpTask{
    UIButton *taskButton = [UIButton buttonWithType:UIButtonTypeCustom];
    taskButton.frame = CGRectMake([SVPSizeUtils svp_width] - 40,[SVPSizeUtils svp_statusFrameHeight] + 10, 20, 25);
    [taskButton setImage:[UIImage imageNamed:@"main_task"] forState:UIControlStateNormal];
    [taskButton addTarget:self action:@selector(setup_svpTaskAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:taskButton];
}

- (void)setupSVP_ScrollMessageData {
    [SVPNetworkCilent svp_setupMainScrollMessageSuccess:^(SVPScrollMessageModel * _Nonnull svp_model) {
        self.svp_messageLabel.text = svp_model.svp_messageData;
        } fail:^(NSError * _Nonnull error, id  _Nullable response) {
            self.svp_messageLabel.text = @"If you have any questions, please contact us!";
        }];
}


- (void)setupSVP_ModeProtocol {
    NSString *svp_ProtocolSelectedString = [SVPLocalDataTool objectForKey:@"selected"];
    if (![SVPNetworkCilent svp_isCheckNameSpaceString:svp_ProtocolSelectedString]) {
        if ([svp_ProtocolSelectedString integerValue] == 0) {
            self.svp_protocolLabel.text = NSLocalizedString(@"protocolA1", nil);
        }
        if ([svp_ProtocolSelectedString integerValue] == 1) {
            self.svp_protocolLabel.text = NSLocalizedString(@"protocolB1", nil);
        }
        if ([svp_ProtocolSelectedString integerValue] == 2) {
            self.svp_protocolLabel.text = NSLocalizedString(@"protocolC1", nil);
        }
    }else{
        self.svp_protocolLabel.text = NSLocalizedString(@"protocolA1", nil);
    }
}

- (void)setup_svpAppleOrderCheckWith:(NSString *)svp_interval {
    NSString *svp_time = [SVPLocalDataTool objectForKey:@"timing"];
    NSInteger svp_checkTime = [svp_time integerValue] + [svp_interval integerValue]*1000;
    NSInteger currentTime = [[SVPDeviceUtils getTimeStamp] integerValue];//当前时间
    NSLog(@"check  %ld",(long)currentTime - svp_checkTime);
    if (svp_checkTime < currentTime) {
        [SVPLocalDataTool setObject:[SVPDeviceUtils getTimeStamp] forKey:@"timing"];
        [SVPNetworkCilent svp_setupCheckAppleOrder];
    }else{
        NSLog(@"not expired");
    }
}

- (void)setup_svpCurrentUsedTraffic:(NSString *)svp_updateString {
    NSString *svp_logTraffic = [SVPLocalDataTool objectForKey:@"logTraffic"];
    NSInteger checkTime = [svp_logTraffic integerValue] + [svp_updateString integerValue]*1000;
    NSInteger currentTime = [[SVPDeviceUtils getTimeStamp] integerValue];//当前时间
    if (checkTime < currentTime) {
        [SVPLocalDataTool setObject:[SVPDeviceUtils getTimeStamp] forKey:@"logTraffic"];
//        [[SVPServerManager shared]svp_setupSVPServer:^(NSError * error) {
//            NSLog(@"%@",error);
//            [[SVPServerManager shared]svp_getTotalDataFlow:^(long totalBytes) {
//                [self setup_svpTrafficLogInfo:[NSString stringWithFormat:@"%ld",totalBytes]];
//            }];
//        }];
    }else{
        NSLog(@"not expired");
    }
}


- (void)setup_svpTrafficLogInfo:(NSString *)svp_usedTraffic {
    [SVPNetworkCilent svp_setupTrafficLog:svp_usedTraffic];
}

#pragma mark - Main UI
- (void)setupSVPMainUI {
    UIScrollView *svp_backgroundScrollView = [[UIScrollView alloc]init];
    svp_backgroundScrollView.frame = CGRectMake(0, 0, [SVPSizeUtils svp_width], [SVPSizeUtils svp_height]);
    svp_backgroundScrollView.backgroundColor = [UIColor clearColor];
    svp_backgroundScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    svp_backgroundScrollView.showsVerticalScrollIndicator = NO;
    svp_backgroundScrollView.contentSize = CGSizeMake([SVPSizeUtils svp_width], [SVPSizeUtils svp_height]+55);
    svp_backgroundScrollView.contentInset = UIEdgeInsetsMake(0, 0, -50, 0);
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view addSubview:svp_backgroundScrollView];
    
    UIImageView *svp_mainBackgroundImageView = [[UIImageView alloc]init];
    svp_mainBackgroundImageView.frame = CGRectMake(0, 0, [SVPSizeUtils svp_width], [SVPSizeUtils svp_height]);
    svp_mainBackgroundImageView.image = [UIImage imageNamed:@"main_backgroundImg"];
    [svp_backgroundScrollView addSubview:svp_mainBackgroundImageView];
    
    UIImageView *svp_topImageView = [[UIImageView alloc]init];
    svp_topImageView.frame = CGRectMake([SVPSizeUtils svp_width]/2 - 358/4, [SVPSizeUtils svp_statusFrameHeight]+10, 358/2, 58/2);
    svp_topImageView.image = [UIImage imageNamed:@"main_titleImg"];
    [svp_backgroundScrollView addSubview:svp_topImageView];
    
    UIView *svp_messageView = [[UIView alloc]init];
    svp_messageView.frame = CGRectMake([SVPSizeUtils svp_width]/2 - 509/4, svp_topImageView.frame.origin.y+ svp_topImageView.frame.size.height+10, 509/2, 60/2);
    svp_messageView.backgroundColor = [UIColor clearColor];
    [svp_backgroundScrollView addSubview:svp_messageView];
    
    UIImageView *svp_messageBg = [[UIImageView alloc]init];
    svp_messageBg.frame = CGRectMake(0, 0, 509/2, 60/2);
    svp_messageBg.image = [UIImage imageNamed:@"main_news_backgroundImg"];
    [svp_messageView addSubview:svp_messageBg];
     
    UIImageView *svp_TrumpImg = [[UIImageView alloc]init];
    svp_TrumpImg.frame = CGRectMake(10, 30/2 - 41/4, 42/2, 41/2);
    svp_TrumpImg.image = [UIImage imageNamed:@"main_newsImg"];
    [svp_messageView addSubview:svp_TrumpImg];
    
    self.svp_messageLabel = [[MarqueeLabel alloc]init];
    self.svp_messageLabel.frame = CGRectMake(10+42/2 + 5, 0, 509/2 - 10 - 42/2 - 10, 30);
    self.svp_messageLabel.marqueeType = MLContinuous;
    self.svp_messageLabel.scrollDuration = 10.0f;
    self.svp_messageLabel.fadeLength = 10.0f;
    self.svp_messageLabel.trailingBuffer = 30.0f;
    self.svp_messageLabel.font = [UIFont systemFontOfSize:15.0f];
    self.svp_messageLabel.textColor = [UIColor colorWithRed:0.40 green:0.38 blue:0.38 alpha:1.00];
    self.svp_messageLabel.userInteractionEnabled = YES;
    [svp_messageView addSubview:self.svp_messageLabel];
    
    UIButton *svp_messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    svp_messageButton.backgroundColor = [UIColor clearColor];
    svp_messageButton.frame =svp_messageView.bounds;
    [svp_messageButton addTarget:self action:@selector(svp_messageButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [svp_messageView addSubview:svp_messageButton];
    
    self.svp_animatedImageView = [[UIImageView alloc]init];
    self.svp_animatedImageView.frame = CGRectMake([SVPSizeUtils svp_width]/2 - 400/4, svp_messageView.frame.origin.y+svp_messageView.frame.size.height + 30, 400/2, 400/2);
    self.svp_animatedImageView.image = [UIImage imageNamed:@"main_connectButton_normal"];
    [svp_backgroundScrollView addSubview:self.svp_animatedImageView];
    
    self.svp_connectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.svp_connectButton.frame = CGRectMake([SVPSizeUtils svp_width]/2 - 400/4, svp_messageView.frame.origin.y+svp_messageView.frame.size.height + 30, 400/2, 400/2);
    self.svp_connectButton.backgroundColor = [UIColor clearColor];
    [self.svp_connectButton setBackgroundImage:[UIImage imageNamed:@"main_connectButton_normal"] forState:UIControlStateNormal];
    [self.svp_connectButton addTarget:self action:@selector(svp_connectButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [svp_backgroundScrollView addSubview:self.svp_connectButton];
    
    self.svp_connectStatusLabel = [[UILabel alloc]init];
    self.svp_connectStatusLabel.frame = CGRectMake(0, self.svp_connectButton.frame.origin.y + self.svp_connectButton.frame.size.height + 10, [SVPSizeUtils svp_width], 21);
    self.svp_connectStatusLabel.textColor = [UIColor whiteColor];
    self.svp_connectStatusLabel.font = [UIFont fontWithName:@"Helvetica-Oblique" size:21];
    self.svp_connectStatusLabel.textAlignment = NSTextAlignmentCenter;
    self.svp_connectStatusLabel.text = @"Connect";
    [svp_backgroundScrollView addSubview:self.svp_connectStatusLabel];
    
    UIView *sperateView = [[UIView alloc]init];
    sperateView.frame = CGRectMake([SVPSizeUtils svp_width]/2 - 0.5, self.svp_connectStatusLabel.frame.origin.y +self.svp_connectStatusLabel.frame.size.height + 40, 1, 70);
    sperateView.backgroundColor = [UIColor clearColor];
    [svp_backgroundScrollView addSubview:sperateView];
    
    
//    UIView *svp_rewardView = [[UIView alloc]init];
//    svp_rewardView.frame = CGRectMake(sperateView.frame.origin.x - 304/2 - 5, self.svp_connectStatusLabel.frame.origin.y +self.svp_connectStatusLabel.frame.size.height + 40, 304/2, 70);
//    [svp_backgroundScrollView addSubview:svp_rewardView];
//
//    UIImageView *svp_rewardImageView = [[UIImageView alloc]init];
//    svp_rewardImageView.frame = CGRectMake(0, 0, 304/2, 70);
//    svp_rewardImageView.image = [UIImage imageNamed:@"main_rewardADImg"];
//    [svp_rewardView addSubview:svp_rewardImageView];
//
//    UILabel *svp_rewardLabel = [[UILabel alloc]init];
//    svp_rewardLabel.frame = CGRectMake(55, 0, 304/2 - 55, 70);
//    svp_rewardLabel.text = @"Reward AD";
//    svp_rewardLabel.textColor = [UIColor whiteColor];
//    svp_rewardLabel.backgroundColor = [UIColor clearColor];
//    svp_rewardLabel.font = [UIFont fontWithName:@"Helvetica-Oblique" size:21];
//    svp_rewardLabel.textAlignment = NSTextAlignmentLeft;
//    svp_rewardLabel.numberOfLines = 0;
//    [svp_rewardView addSubview:svp_rewardLabel];
//
//    UIButton *svp_rewardButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    svp_rewardButton.frame =CGRectMake(0, 0, 304/2, 70);;
//    svp_rewardButton.backgroundColor = [UIColor clearColor];
//    [svp_rewardButton addTarget:self action:@selector(svp_rewardADAction) forControlEvents:UIControlEventTouchUpInside];
//    [svp_rewardView addSubview:svp_rewardButton];
    
    
    UIView *svp_protocolView = [[UIView alloc]init];
    svp_protocolView.frame = CGRectMake(sperateView.frame.origin.x + 5, self.svp_connectStatusLabel.frame.origin.y +self.svp_connectStatusLabel.frame.size.height + 40, 304/2, 70);
    [svp_backgroundScrollView addSubview:svp_protocolView];
    
    UIImageView *svp_protocolImageView = [[UIImageView alloc]init];
    svp_protocolImageView.frame = CGRectMake(0, 0, 304/2, 70);
    svp_protocolImageView.image = [UIImage imageNamed:@"main_ProtocolImg"];
    [svp_protocolView addSubview:svp_protocolImageView];
    
    self.svp_protocolLabel = [[UILabel alloc]init];
    self.svp_protocolLabel.frame = CGRectMake(50, 0, 304/2 - 65, 70);
    NSString *svp_ProtocolString = [SVPLocalDataTool objectForKey:@"selected"];
    if (![SVPNetworkCilent svp_isCheckNameSpaceString:svp_ProtocolString]) {
        if ([svp_ProtocolString integerValue] == 0) {
            self.svp_protocolLabel.text = NSLocalizedString(@"protocolA1", nil);
        }
        if ([svp_ProtocolString integerValue] == 1) {
            self.svp_protocolLabel.text = NSLocalizedString(@"protocolB1", nil);
        }
        if ([svp_ProtocolString integerValue] == 2) {
            self.svp_protocolLabel.text = NSLocalizedString(@"protocolC1", nil);
        }
    }else{
        self.svp_protocolLabel.text = NSLocalizedString(@"protocolA1", nil);
    }
//    self.svp_protocolLabel.text = @"ProtocolA";
    self.svp_protocolLabel.textColor = [UIColor whiteColor];
    self.svp_protocolLabel.backgroundColor = [UIColor clearColor];
    self.svp_protocolLabel.font = [UIFont fontWithName:@"Helvetica-Oblique" size:21];
    self.svp_protocolLabel.textAlignment = NSTextAlignmentLeft;
    self.svp_protocolLabel.numberOfLines = 0;
    [svp_protocolView addSubview:self.svp_protocolLabel];
    
    UIButton *svp_protocolButton = [UIButton buttonWithType:UIButtonTypeCustom];
    svp_protocolButton.frame =CGRectMake(0, 0, 304/2, 70);;
    svp_protocolButton.backgroundColor = [UIColor clearColor];
    [svp_protocolButton addTarget:self action:@selector(svp_protocolButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [svp_protocolView addSubview:svp_protocolButton];
    
    UIView *svp_linesSelectView = [[UIView alloc]init];
    svp_linesSelectView.frame = CGRectMake(sperateView.frame.origin.x - 304/2 - 5, self.svp_connectStatusLabel.frame.origin.y+self.svp_connectStatusLabel.frame.size.height + 40, 304/2, 70);
    [svp_backgroundScrollView addSubview:svp_linesSelectView];
    
    UIImageView *svp_linesSelectImageView = [[UIImageView alloc]init];
    svp_linesSelectImageView.frame = CGRectMake(0, 0, 304/2, 70);
    svp_linesSelectImageView.image = [UIImage imageNamed:@"main_lineImg"];
    [svp_linesSelectView addSubview:svp_linesSelectImageView];
    
    self.svp_linesLabel = [[UILabel alloc]init];
    self.svp_linesLabel.frame = CGRectMake(55, 0, 304/2 - 65, 70);
    self.svp_linesLabel.text = @"Optimal location";
    self.svp_linesLabel.textColor = [UIColor whiteColor];
    self.svp_linesLabel.backgroundColor = [UIColor clearColor];
    self.svp_linesLabel.font = [UIFont fontWithName:@"Helvetica-Oblique" size:21];
    self.svp_linesLabel.textAlignment = NSTextAlignmentLeft;
    self.svp_linesLabel.numberOfLines = 0;
    [svp_linesSelectView addSubview:self.svp_linesLabel];
    
    UIButton *svp_linesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    svp_linesButton.frame =CGRectMake(0, 0, 304/2, 70);;
    svp_linesButton.backgroundColor = [UIColor clearColor];
    [svp_linesButton addTarget:self action:@selector(svp_linesButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [svp_linesSelectView addSubview:svp_linesButton];
    
    [self setup_svpAnimatedAction];
}

- (void)setup_svpAnimatedAction {
    
    NSMutableArray *animatedImageViewArray = [NSMutableArray array];
    for (int i = 0; i < 145; i++) {
        NSString *string = [NSString stringWithFormat:@"svp_animated%i",i];
        NSLog(@"animated：%@",string);
        NSArray *array = [NSArray arrayWithObjects:
                          [UIImage imageNamed:string], nil];
        [animatedImageViewArray addObjectsFromArray:array];
    }
    [self.svp_animatedImageView setAnimationImages:animatedImageViewArray];
    [self.svp_animatedImageView setAnimationDuration:4];
    [self.svp_animatedImageView setAnimationRepeatCount:MAXFLOAT];
//    [self.svp_animatedImageView startAnimating];
}


#pragma mark - button click action
- (void)svp_messageButtonClick {
    
}

- (void)svp_connectButtonClick:(UIButton *)sender {
    if ([SVPNServerManager shareInstance].status == NEVPNStatusConnected) {
        [self stopConnect];
    }else if ([SVPNServerManager shareInstance].status == NEVPNStatusDisconnected) {
        [self startConnet];
    }else if ([SVPNServerManager shareInstance].status == NEVPNStatusConnecting) {
        [self connecting];
    }else if ([SVPNServerManager shareInstance].status == NEVPNStatusConnected) {
        
    }else if ([SVPNServerManager shareInstance].status == NEVPNStatusDisconnecting) {
        
    }else {
        [self startConnet];
    }
    
//    [self setup_svpAnimatedAction];
//    NSDictionary* dic = @{@"remainMins":@(4301),@"host":@"141.164.61.70", @"port":@"443", @"password":@"754d50c7"};
//
//    [[SVPNServerManager shareInstance] startVPN:dic completion:^(NSError * _Nonnull error) {
//
//    }];
    
    return;
    
    NSData *svp_lineData = [SVPLocalDataTool objectForKey:@"ConfigurationV"];
    NSDictionary *LinesDic = [NSKeyedUnarchiver unarchiveObjectWithData:svp_lineData];
    NSString *svp_LineStatus = [SVPLocalDataTool objectForKey:@"lineStatus"];
    NSString *svp_isTrailString = [SVPLocalDataTool objectForKey:@"noTraffic"];
    svp_isTrailString =  @"1";
    
    if ([svp_LineStatus integerValue] == 2) {
        [MBProgressManager showBriefAlert:NSLocalizedString(@"lineFull", nil) time:2];
        return;
    }
    
    NSMutableDictionary * svp_LinesDic = [NSMutableDictionary dictionaryWithDictionary:LinesDic];
    [svp_LinesDic setValue:@"use.rdyxj.com" forKey:@"ikev2_id"];
    [svp_LinesDic setValue:@"123456" forKey:@"ikev2_password"];
    [svp_LinesDic setValue:@"45.32.106.225" forKey:@"ip"];

    
    if ([svp_LinesDic objectForKey:@"ikev2_id"] == nil || [[svp_LinesDic objectForKey:@"ikev2_password"] isEqualToString:@""]) {
        [MBProgressManager showBriefAlert:NSLocalizedString(@"LineProblem", nil) time:2];
        return;
    }
    NSString *svp_selectedString = [SVPLocalDataTool objectForKey:@"selected"];
    if (svp_selectedString.length ==0 || svp_selectedString == nil) {
        svp_selectedString = @"0";
    }
    if (svp_selectedString) {
        if ([svp_selectedString integerValue] == 0) {
            SVPServerStatus status = [self.svp_connector getCurrentSVPServerStatus];
            if (status == SVPServerStatusConnecting || status == SVPServerStatusConnecting) {
                [self.svp_connector stopSVPServerConnectSuccess:^{
                }];
            }
            
//            BOOL svp_active = [[SVPServerManager shared] svp_isActive:self.svp_serverID];
            BOOL svp_active = NO;
            if (svp_active == NO && sender.selected == NO) {
                if ([svp_isTrailString integerValue] == 1){
                    [sender setSelected:YES];
                    [self setup_svpAnimatedAction];
                    [self.svp_connectButton setBackgroundImage:nil forState:UIControlStateNormal];
                    self.svp_connectStatusLabel.text = NSLocalizedString(@"Connecting", nil);
                    self.svp_connectButton.userInteractionEnabled = YES;
                    
//                    NSDictionary * dic = @{@"password":@"754d50c7",@"host":@"141.164.61.70",@"port":@"443",@"remainMins":@"4301"};
                    NSString * interval = [[NSUserDefaults standardUserDefaults] objectForKey:@"REMAINMINS"];
                    NSDictionary* dic = @{@"remainMins":interval,@"host":@"tj1925.9527.click", @"port":@"443", @"password":@"EF14C996-DEB9-4750-96BB-6C1DA01AADA9"};
                    
                    [[SVPNServerManager shareInstance] startVPN:dic completion:^(NSError * _Nonnull error) {
                        if ([SVPNServerManager shareInstance].status == NEVPNStatusConnected) {
                            [self setup_svpTrafficTrialSetting:[self.svp_isVIPString integerValue]];
                            [self setup_svpTimeTrialSetting:[self.svp_isVIPString integerValue]];
                            [self.svp_connectButton setBackgroundImage:[UIImage imageNamed:@"main_connectButton_selected"] forState:UIControlStateNormal];
                            self.svp_connectStatusLabel.text = NSLocalizedString(@"Connected", nil);
                            [self.svp_animatedImageView stopAnimating];
                            [SVPNetworkCilent svp_setupLineConnectSuccess:[svp_LinesDic objectForKey:@"ip"]];
//                            BOOL svp_active = [[SVPServerManager shared]svp_isActive:self.svp_serverID];
                            if (svp_active == NO) {
//                                [[SVPServerManager shared] svp_stop:self.svp_serverID];
                                [self setup_svpTrafficTrialSetting:[self.svp_isVIPString integerValue]];
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    [self svp_setupConnectionConfiguration];
                                    [self svp_connectButtonClick:self.svp_connectButton];
                                });
                            }else{
                                self.svp_connectButton.selected = YES;
                                [self.svp_connectButton setBackgroundImage:[UIImage imageNamed:@"main_connectButton_selected"] forState:UIControlStateNormal];
                                self.svp_connectStatusLabel.text = NSLocalizedString(@"Connected", nil);
                            }
                        }else {
                            [sender setSelected:NO];
                            [self.svp_connectButton setBackgroundImage:[UIImage imageNamed:@"main_connectButton_normal"] forState:UIControlStateNormal];
                            self.svp_connectStatusLabel.text = NSLocalizedString(@"Connect", nil);
                            NSLog(@"Failed to connected");
//                            [[SVPServerManager shared] svp_stop:self.svp_serverID];
                            [[SVPNServerManager shareInstance] stopVPN];
                            if ([svp_LinesDic objectForKey:@"ip"] != nil) {
                                [SVPNetworkCilent svp_setupLineConnectFailure:[svp_LinesDic objectForKey:@"ip"]];
                            }else{
                                [MBProgressManager showBriefAlert:NSLocalizedString(@"Parameter", nil) time:2];
                            }
                        }
                    }];
//                    [[SVPServerManager shared]svp_start:self.svp_connection completion:^(SVPServerErrorCode svp_errorCode) {
//                        if (svp_errorCode == SVPServerErrorCodeNoError) {
//                            [self setup_svpTrafficTrialSetting:[self.svp_isVIPString integerValue]];
//                            [self setup_svpTimeTrialSetting:[self.svp_isVIPString integerValue]];
//                            [self.svp_connectButton setBackgroundImage:[UIImage imageNamed:@"main_connectButton_selected"] forState:UIControlStateNormal];
//                            self.svp_connectStatusLabel.text = NSLocalizedString(@"Connected", nil);
//                            [self.svp_animatedImageView stopAnimating];
//                            [SVPNetworkCilent svp_setupLineConnectSuccess:[svp_LinesDic objectForKey:@"ip"]];
//                            BOOL svp_active = [[SVPServerManager shared]svp_isActive:self.svp_serverID];
//                            if (svp_active == NO) {
//                                [[SVPServerManager shared] svp_stop:self.svp_serverID];
//                                [self setup_svpTrafficTrialSetting:[self.svp_isVIPString integerValue]];
//                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                                    [self svp_setupConnectionConfiguration];
//                                    [self svp_connectButtonClick:self.svp_connectButton];
//                                });
//                            }else{
//                                self.svp_connectButton.selected = YES;
//                                [self.svp_connectButton setBackgroundImage:[UIImage imageNamed:@"main_connectButton_selected"] forState:UIControlStateNormal];
//                                self.svp_connectStatusLabel.text = NSLocalizedString(@"Connected", nil);
//                            }
//                        }else {
//                            [sender setSelected:NO];
//                            [self.svp_connectButton setBackgroundImage:[UIImage imageNamed:@"main_connectButton_normal"] forState:UIControlStateNormal];
//                            self.svp_connectStatusLabel.text = NSLocalizedString(@"Connect", nil);
//                            NSLog(@"Failed to connected");
//                            [[SVPServerManager shared] svp_stop:self.svp_serverID];
//                            if ([svp_LinesDic objectForKey:@"ip"] != nil) {
//                                [SVPNetworkCilent svp_setupLineConnectFailure:[svp_LinesDic objectForKey:@"ip"]];
//                            }else{
//                                [MBProgressManager showBriefAlert:NSLocalizedString(@"Parameter", nil) time:2];
//                            }
//                        }
//                    }];
                }else if ([self.svp_isVIPString integerValue] == 0 && [self.svp_is_trail integerValue] == 0){
                    [MBProgressManager showBriefAlert:NSLocalizedString(@"DataError", nil) time:2];
                }else if ([svp_isTrailString integerValue] == 0){
                    if ([self.svp_allow_trial_time integerValue] == 1) {
                        [MBProgressManager showBriefAlert:NSLocalizedString(@"TimeOver", nil) time:2];
                    }
                    if ([self.svp_allow_trial_traffic integerValue] == 1) {
                        [MBProgressManager showBriefAlert:NSLocalizedString(@"Exhausted", nil) time:2];
                    }
                }
            }else {
                [self svp_serverStopDisconnect:NO];
            }
            
        }else if ([svp_selectedString integerValue] == 1 || [svp_selectedString integerValue] == 2){
            [self svp_serverStopDisconnect:NO];
            if (self.svp_serverInfo.svp_serverAddress.length < 1) {
                [MBProgressManager showBriefAlert:@"Lines Missing Infomation" time:2];
            }
            if ([svp_isTrailString integerValue] == 1) {
                [self.svp_connector checkSVPServerPreferenceSuccess:^(BOOL isInstalled) {
                    if (isInstalled) {
                        SVPServerStatus svp_status = [self.svp_connector getCurrentSVPServerStatus];
                        if (svp_status == SVPServerStatusDisconnected && sender.selected == NO) {
                            [sender setSelected:YES];
                            [self.svp_connector modifySVPServerPreferenceWithData:self.svp_serverInfo success:^{
                                [self.svp_connector startSVPServerConnectSuccess:^{
                                                                    
                                }];
                            }];
                        }else{
                            [self svp_serverStopDisconnect:NO];
                        }
                        if (svp_status == SVPServerStatusConnecting || svp_status == SVPServerStatusConnected) {
                            [self.svp_connector stopSVPServerConnectSuccess:^{
                                [self setup_svpTrafficTrialSetting:[self.svp_isVIPString integerValue]];
                            }];
                        }
                    }else {
                        [self.svp_connector createSVPServerPreferenceWithData:self.svp_serverInfo success:^{
                            [self.svp_connector startSVPServerConnectSuccess:^{
                                
                            }];
                        }];
                    }
                }];
            }else if ([self.svp_isVIPString integerValue] == 0 && [self.svp_is_trail integerValue] == 0){
                [MBProgressManager showBriefAlert:NSLocalizedString(@"DataError", nil) time:2];
            }else if ([svp_isTrailString integerValue] == 0){
                if ([self.svp_allow_trial_time integerValue] == 1) {
                    [MBProgressManager showBriefAlert:NSLocalizedString(@"TimeOver", nil) time:2];
                }
                if ([self.svp_allow_trial_traffic integerValue] == 1) {
                    [MBProgressManager showBriefAlert:NSLocalizedString(@"Exhausted", nil) time:2];
                }
            }
        }
    }else {
        NSLog(@"==============================");
    }
}

- (void)startConnet {
//    [self setup_svpAnimatedAction];
    [self.svp_animatedImageView startAnimating];
    NSString * minute = [[NSUserDefaults standardUserDefaults] objectForKey:@"REMAINMINS"];
    NSDictionary* dic = @{@"remainMins":minute,@"host":@"141.164.61.70", @"port":@"443", @"password":@"754d50c7"};
    [[SVPNServerManager shareInstance] startVPN:dic completion:^(NSError * _Nonnull error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.svp_animatedImageView stopAnimating];
            [self.svp_connectButton setBackgroundImage:[UIImage imageNamed:@"main_connectButton_selected"] forState:UIControlStateNormal];
            self.svp_connectStatusLabel.text = NSLocalizedString(@"Connected", nil);
        });
    }];
}

- (void)connecting {
    [self.svp_connectButton setBackgroundImage:nil forState:UIControlStateNormal];
    self.svp_connectStatusLabel.text = NSLocalizedString(@"Connecting", nil);
    self.svp_connectButton.userInteractionEnabled = YES;
}

- (void)stopConnect {
    [self.svp_animatedImageView startAnimating];
//    [self setup_svpAnimatedAction];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[SVPNServerManager shareInstance] stopVPN];
        [self.svp_animatedImageView stopAnimating];
        [self.svp_connectButton setBackgroundImage:[UIImage imageNamed:@"main_connectButton_normal"] forState:UIControlStateNormal];
        self.svp_connectStatusLabel.text = NSLocalizedString(@"Connect", nil);
    });
}

- (void)svp_rewardADAction {
    if ([[self.svp_mainModel.svp_Award_adDic objectForKey:@"switch"]integerValue]==1 && [[self.svp_mainModel.svp_Award_adDic objectForKey:@"award_1_switch"]integerValue]==1) {
        NSDictionary *awardDic = self.svp_mainModel.svp_Award_adDic[@"award_1_data"];
        [self svp_setupAwardADWith:[awardDic objectForKey:@"id"]];
    }else{
        [MBProgressManager showBriefAlert:NSLocalizedString(@"NoAds", nil) time:2];
    }
}


- (void)svp_protocolButtonAction {
    SVPModeViewController *svpModeVC = [[SVPModeViewController alloc]init];
    svpModeVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:svpModeVC animated:YES];
}

- (void)svp_linesButtonAction {
    SVPLinesViewController *svpLinesVC = [[SVPLinesViewController alloc]init];
    svpLinesVC.hidesBottomBarWhenPushed = YES;
    svpLinesVC.svp_allow_trial_time = self.svp_allow_trial_time;
    svpLinesVC.svp_allow_trial_traffic = self.svp_allow_trial_traffic;
    svpLinesVC.svp_is_trial = self.svp_is_trail;
    svpLinesVC.svp_lineIsVIP = self.svp_isVIPString;
    svpLinesVC.delegate = self;
    [self.navigationController pushViewController:svpLinesVC animated:YES];
}

- (void)setup_svpTaskAction {
    
}

#pragma mark - connection status
- (void)svp_setupLinesSelectedAutoConnect:(SVPLinesViewController *)svp_linesVC {
    self.svp_connectButton.userInteractionEnabled = NO;
    [self setup_svpIKevMode];
    
    NSString *svp_lineName = [SVPLocalDataTool objectForKey:@"lineName"];
    if (svp_lineName != nil) {
        self.svp_linesLabel.text = svp_lineName;
    }else{
        self.svp_linesLabel.text = NSLocalizedString(@"ChooseYourLocation", nil);
    }
    
    [self svp_serverStopDisconnect:NO];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self svp_setupConnectionConfiguration];
        [self svp_connectButtonClick:self.svp_connectButton];
    });
}

- (void)svp_serverStopDisconnect:(BOOL)svp_selected {
//    [[SVPServerManager shared] svp_stop:self.svp_serverID];
    [[SVPNServerManager shareInstance] stopVPN];
    [self.svp_connectButton setSelected:svp_selected];
    [self.svp_connectButton setBackgroundImage:[UIImage imageNamed:@"main_connectButton_normal"] forState:UIControlStateNormal];
    self.svp_connectStatusLabel.text = NSLocalizedString(@"Connect", nil);
    self.svp_connectButton.userInteractionEnabled = YES;
    [self setup_svpTrafficTrialSetting:[self.svp_isVIPString integerValue]];
}

- (void)svp_setupConnectionConfiguration {
    NSString *svp_FreeString = [SVPLocalDataTool objectForKey:@"pingSubnetFree"];
    NSString *svp_VipString = [SVPLocalDataTool objectForKey:@"pingSubnetVIP"];
    NSData *svp_statusData = [SVPLocalDataTool objectForKey:@"ConfigurationV"];
    NSDictionary *localDataDic = [NSKeyedUnarchiver unarchiveObjectWithData:svp_statusData];
    
    
    
    svp_FreeString = @"141.164.61.70";
    svp_VipString = @"141.164.61.70";
    NSMutableDictionary * svp_localDataDic = [NSMutableDictionary dictionaryWithDictionary:localDataDic];
    [svp_localDataDic setValue:@"22131" forKey:@"port"];
    [svp_localDataDic setValue:@"CespiNpVsoi2016" forKey:@"password"];
    [svp_localDataDic setValue:@"141.164.61.70" forKey:@"ip"];
    [svp_localDataDic setValue:@"chacha20" forKey:@"method"];
    [svp_localDataDic setValue:@"8.8.8.8,8.4.4.4" forKey:@"dns"];
    
    if (svp_localDataDic != nil) {
        self.svp_serverID = @"server002";
        NSMutableDictionary* svp_ServerConfig = [[NSMutableDictionary alloc] init];
        [svp_ServerConfig setValue:svp_localDataDic[@"ip"] forKey:@"host"];
        [svp_ServerConfig setValue:svp_localDataDic[@"port"] forKey:@"port"];
        [svp_ServerConfig setValue:svp_localDataDic[@"password"] forKey:@"password"];
        [svp_ServerConfig setValue:svp_localDataDic[@"method"] forKey:@"method"];
        [svp_ServerConfig setValue:svp_localDataDic[@"dns"] forKey:@"dns"];
        [svp_ServerConfig setValue:svp_FreeString forKey:@"pingSubnetFree"];
        [svp_ServerConfig setValue:svp_VipString forKey:@"pingSubnetVIP"];
        self.svp_connection = [[SVPServerConnection alloc]initWithID:self.svp_serverID config:svp_ServerConfig];
        NSLog(@"config:%@",svp_ServerConfig);
    }
}

- (void)setup_svpIKevMode {
    self.svp_connector = [SVPConnector svp_ServerConnector];
    self.svp_connector.delegate = (id)self;
    NSData *svp_statusData = [SVPLocalDataTool objectForKey:@"ConfigurationV"];
    NSDictionary *svp_localDataDic = [NSKeyedUnarchiver unarchiveObjectWithData:svp_statusData];
    if ([svp_localDataDic objectForKey:@"ikev2_id"] == nil || [[svp_localDataDic objectForKey: @"ikev2_password"] isEqualToString:@""]) {
        return;
    }
    SVPSeverInfo *svp_serverInfo = [[SVPSeverInfo alloc] init];
    svp_serverInfo.svp_serverAddress = [svp_localDataDic objectForKey:@"ip"];
    svp_serverInfo.svp_remoteID = [svp_localDataDic objectForKey:@"ikev2_id"];
    svp_serverInfo.svp_username = [svp_localDataDic objectForKey:@"ikev2_username"];
    svp_serverInfo.svp_password = [svp_localDataDic objectForKey:@"ikev2_password"];
    svp_serverInfo.svp_sharedSecret = [svp_localDataDic objectForKey:@"ikev2_secret"];
    svp_serverInfo.svp_preferenceTitle = @"super vpn pro";
    _svp_serverInfo = svp_serverInfo;
}

- (void)setup_svpConnectionStatus {
    [self setup_svpIKevMode];
    NSString *svp_SelectedString = [SVPLocalDataTool objectForKey:@"selected"];
//    if (svp_SelectedString) {
//        if ([svp_SelectedString integerValue] == 0) {
//            SVPServerManager.shared.svpServerStatusObserver = ^(NEVPNStatus status, NSString *connectionID){
//                if (connectionID.length > 0) {
//                    self.svp_connectButton.selected = YES;
//                    [self.svp_connectButton setBackgroundImage:[UIImage imageNamed:@"main_connectButton_selected"] forState:UIControlStateNormal];
//                    self.svp_connectStatusLabel.text = NSLocalizedString(@"Connected", nil);
//                }
//            };
//        }
//        if ([svp_SelectedString integerValue] == 1 || [svp_SelectedString integerValue] == 2) {
//            [self.svp_connector checkSVPServerPreferenceSuccess:^(BOOL isInstalled) {
//
//            SVPServerStatus status = [self.svp_connector getCurrentSVPServerStatus];
//                if (status == SVPServerStatusConnected) {
//                    self.svp_connectButton.selected = YES;
//                    [self.svp_connectButton setBackgroundImage:[UIImage imageNamed:@"main_connectButton_selected"] forState:UIControlStateNormal];
//                    self.svp_connectStatusLabel.text = NSLocalizedString(@"Connected", nil);
//                }
//            }];
//        }
//    }else{
//        SVPServerManager.shared.svpServerStatusObserver = ^(NEVPNStatus status, NSString *connectionID){
//            if (connectionID.length > 0) {
//                self.svp_connectButton.selected = YES;
//                [self.svp_connectButton setBackgroundImage:[UIImage imageNamed:@"main_connectButton_selected"] forState:UIControlStateNormal];
//                self.svp_connectStatusLabel.text = NSLocalizedString(@"Connected", nil);
//            }
//        };
//    }
}


- (void)svpServerConnectionDidRecieveError:(SVPServerConnectorError)error {
    switch (error) {
        case SVPServerConnectorErrorNone:
            break;
        case SVPServerConnectorErrorLoadPrefrence:
            break;
        case SVPServerConnectorErrorSavePrefrence:
            break;
        case SVPServerConnectorErrorRemovePrefrence:
            break;
        case SVPServerConnectorErrorStartVPNConnect:
            break;
        default:
            break;
    }
}

- (void)svpServerStatusDidChange:(SVPServerStatus)status {
    switch (status) {
        case SVPServerStatusInvalid:
            break;
        case SVPServerStatusConnected:
        {
            NSData *svp_linesData = [SVPLocalDataTool objectForKey:@"ConfigurationV"];
            NSDictionary *svp_lineDic = [NSKeyedUnarchiver unarchiveObjectWithData:svp_linesData];
            [self setup_svpTrafficTrialSetting:[self.svp_isVIPString integerValue]];
            [self setup_svpTimeTrialSetting:[self.svp_isVIPString integerValue]];
            [self.svp_connectButton setBackgroundImage:[UIImage imageNamed:@"main_connectButton_selected"] forState:UIControlStateNormal];
            self.svp_connectStatusLabel.text = NSLocalizedString(@"Connected", nil);
            [self.svp_animatedImageView stopAnimating];
            [SVPNetworkCilent svp_setupLineConnectSuccess:[svp_lineDic objectForKey:@"ip"]];
        }
            break;
        case SVPServerStatusDisconnected:
        {
            NSString *svp_SelectedString = [SVPLocalDataTool objectForKey:@"selected"];
            if ([svp_SelectedString integerValue] == 1 || [svp_SelectedString integerValue] == 2) {
                [self.svp_connectButton setSelected:NO];
                [self.svp_connectButton setBackgroundImage:[UIImage imageNamed:@"main_connectButton_normal"] forState:UIControlStateNormal];
                self.svp_connectStatusLabel.text = NSLocalizedString(@"Connect", nil);
            }
        }
            break;
        case SVPServerStatusConnecting:
        {
            NSString *svp_SelectedString = [SVPLocalDataTool objectForKey:@"selected"];
            if ([svp_SelectedString integerValue] == 1 || [svp_SelectedString integerValue] == 2) {
                [self setup_svpAnimatedAction];
                [self.svp_connectButton setBackgroundImage:nil forState:UIControlStateNormal];
                self.svp_connectStatusLabel.text = NSLocalizedString(@"Connecting", nil);
                self.svp_connectButton.userInteractionEnabled = YES;
            }
        }
            break;
        case SVPServerStatusDisconnecting:
            break;
        default:
            break;
    }
}

- (void)svp_comeBack {
    
}

#pragma mark - ad

- (void)setup_svpADInfo {
    CGFloat safeBottom;
    if ([SVPSizeUtils svp_isIPhoneNotchScreen]) {
        safeBottom = 34.0;
    }else {
        safeBottom = 0.0;
    }
    NSLog(@"=======================%@",self.svp_mainModel.svp_AdDataDic);
    if([[self.svp_mainModel.svp_AdDataDic objectForKey:@"switch"]integerValue] == 1){
        NSString *svp_banner_switch = [[NSString alloc]initWithFormat:@"%@",[self.svp_mainModel.svp_AdDataDic objectForKey:@"banner_1_switch"]];
        
        if ([svp_banner_switch isEqualToString:@"1"]) {
            NSDictionary *bannerDic = self.svp_mainModel.svp_AdDataDic[@"banner_1_data"];
            NSString *svp_type = [bannerDic objectForKey:@"type"];
            if ([svp_type isEqualToString:@"admob"]) {
        
                SVPAdmobBannerView *svp_bannerView = [[SVPAdmobBannerView alloc] init];
                svp_bannerView.frame = CGRectMake(0,[SVPSizeUtils svp_height] - 49 - 50 - safeBottom, [SVPSizeUtils svp_width], 50);
                svp_bannerView.bannerID = [bannerDic objectForKey:@"id"];
                [svp_bannerView setup_svpAdmobBannerView:self AdUnitID:[bannerDic objectForKey:@"unit_key"]];
                [self.view addSubview:svp_bannerView];
            }else if([svp_type isEqualToString:@"vungle"]){
                SVPVungleBannerView *svp_vungleBanner = [[SVPVungleBannerView alloc]initWithFrame:CGRectMake(self.view.center.x - 150,[SVPSizeUtils svp_height] - 44 - 50,300, 50)];
                svp_vungleBanner.svp_ID = [bannerDic objectForKey:@"id"];
                svp_vungleBanner.svp_unit_key = [bannerDic objectForKey:@"unit_key"];
                [svp_vungleBanner setup_svpVungleBannerView:self ProjectKey:[bannerDic objectForKey:@"project_key"]];
                [self.view addSubview:svp_vungleBanner];
            }else{
                SVPCustomBannerView *svp_customBannerView = [[SVPCustomBannerView alloc]initWithFrame:CGRectMake(0,[SVPSizeUtils svp_height] - 49 - safeBottom - 50, [SVPSizeUtils svp_width], 50)];
                svp_customBannerView.delegate = self;
                svp_customBannerView.svp_customBannerID = [bannerDic objectForKey:@"id"];
                svp_customBannerView.svp_BannerImageUrl = bannerDic[@"image"];
                svp_customBannerView.svp_BannerUrl = bannerDic[@"url"];
                svp_customBannerView.svp_BannerTag = bannerDic[@"tag"];
                [self.view addSubview:svp_customBannerView];
            }
        }
    }else {
        NSLog(@"ad limit ");
    }
}

- (void)svp_setupAwardADWith:(NSString*)svp_awardID {
    [MBProgressManager showLoading];
    NSString *svp_path = @"/v1/ad/video/status";
    NSString *svp_stringTag;
    if ([SVPDeviceUtils svp_getNeedStill]) {
        svp_stringTag = [SVPDeviceUtils svp_getAuthorization];
    }else{
        svp_stringTag = @"";
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[SVPDeviceUtils getBundleVersion] forKey:@"app_version"];
    [dic setObject:svp_awardID forKey:@"id"];
    [dic setObject:svp_stringTag forKey:@"tag"];
    [SVPInterfaceManager svp_get:svp_path withParams:dic success:^(id  _Nullable response) {
        NSDictionary *svp_resultDic = (NSDictionary *)response;
        if ([[svp_resultDic objectForKey:@"data"]integerValue] == 1) {
            NSDictionary *awardDic = self.svp_mainModel.svp_Award_adDic[@"award_1_data"];
            [self setup_svpAwardADWith:[awardDic objectForKey:@"type"]];
        }else{
            [MBProgressManager hideAlert];
            [MBProgressManager showBriefAlert:NSLocalizedString(@"RewardFailure", nil) time:2];
        }
        } failure:^(NSError * _Nonnull error, id  _Nullable response) {
            
        }];
}

- (void)setup_svpAwardADWith:(NSString*)adType {
    [MBProgressManager hideAlert];
    NSDictionary *awardDic = self.svp_mainModel.svp_Award_adDic[@"award_1_data"];
    if ([adType isEqualToString:@"admob"]) {
        
        NSString *svp_admobString = [NSString stringWithFormat:@"%@",[awardDic objectForKey:@"unit_key"]];
        if (svp_admobString.length == 0 || svp_admobString == nil) {
            [MBProgressManager showBriefAlert:NSLocalizedString(@"RewardFailure", nil) time:2];
        }else {
        SVPAdmobRewardADView *svp_rewardedAdView = [[SVPAdmobRewardADView alloc] init];
        [svp_rewardedAdView setup_svpAdmobRewardedAdView:self AdUnitID:[awardDic objectForKey:@"unit_key"]];
        svp_rewardedAdView.rewardedID = [awardDic objectForKey:@"id"];
        [self.view addSubview:svp_rewardedAdView];
        }
       
    }else if ([adType isEqualToString:@"vungle"]){
        NSString *svp_vungleString = [NSString stringWithFormat:@"%@",[awardDic objectForKey:@"unit_key"]];
        if (svp_vungleString.length == 0 || svp_vungleString == nil){
            [MBProgressManager showBriefAlert:NSLocalizedString(@"RewardFailure", nil) time:2];
        }else {
        SVPVungleInterstitialView *svp_vungleInterstitial = [[SVPVungleInterstitialView alloc]init];
        svp_vungleInterstitial.svp_AwardStatus = @"1";
        svp_vungleInterstitial.svp_ID = [awardDic objectForKey:@"id"];
        svp_vungleInterstitial.svp_unit_key = [awardDic objectForKey:@"unit_key"];
        [svp_vungleInterstitial setup_svpVungleInterstitialView:self ProjectKey:[awardDic objectForKey:@"project_key"]];
        [self.view addSubview:svp_vungleInterstitial];
        }
    }else {
        SVPCustomInterstitalView *svp_customInterstitalView = [[SVPCustomInterstitalView alloc]initWithFrame:CGRectMake(0,0, [SVPSizeUtils svp_width], [SVPSizeUtils svp_height])];
        svp_customInterstitalView.delegate = self;
        svp_customInterstitalView.svp_AwardStatus = @"1";
        svp_customInterstitalView.svp_CustomInterstitialID = [awardDic objectForKey:@"id"];
        svp_customInterstitalView.svp_InterstitialImageUrl = [awardDic objectForKey:@"image"];
        svp_customInterstitalView.svp_InterstitialUrl = [awardDic objectForKey:@"url"];
        svp_customInterstitalView.svp_InterstitialTag = [awardDic objectForKey:@"tag"];
        [[UIApplication sharedApplication].keyWindow addSubview:svp_customInterstitalView];
    }
}

- (void)setup_svpInterstitialViewClick:(SVPCustomInterstitalView *)ConnectView {
    
}

- (void)setup_svpBannerViewClick:(SVPCustomBannerView *)bannerView {
    
}
@end
