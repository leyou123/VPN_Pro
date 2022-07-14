//
//  SVPSettingsViewController.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/8.
//

#import "SVPSettingsViewController.h"
#import "SVPMessageCenterViewController.h"
#import "SVPPurchaseHistoryViewController.h"
#import "SVPNetworkCilent.h"

#import "SVPSizeUtils.h"
#import "SVPSettingModel.h"
#import "MBProgressManager.h"

#import "SVPDateUtils.h"

@interface SVPSettingsViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic)UITableView *svp_settingTableView;
@property (strong, nonatomic)SVPSettingModel *svp_settingModel;
@property (nonatomic, copy) NSString * expireDate;
@end

@implementation SVPSettingsViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
//    [self setupsvp_SettingsData];
    [self setup_svpSettingUI];
    self.expireDate = [SVPDateUtils getExpireDate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)setup_svpSettingUI {
    UIImageView *svp_topBgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [SVPSizeUtils svp_width], [SVPSizeUtils svp_statusFrameHeight]+self.navigationController.navigationBar.frame.size.height)];
    svp_topBgImageView.image = [UIImage imageNamed:@"main_topBg"];
    [self.view addSubview:svp_topBgImageView];
    
    self.svp_settingTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,self.navigationController.navigationBar.frame.size.height + [SVPSizeUtils svp_statusFrameHeight],[SVPSizeUtils svp_width], [SVPSizeUtils svp_height] - self.navigationController.navigationBar.frame.size.height - [SVPSizeUtils svp_statusFrameHeight]) style:UITableViewStylePlain];
    self.svp_settingTableView.delegate = self;
    self.svp_settingTableView.dataSource = self;
    self.svp_settingTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.svp_settingTableView.tableFooterView = [[UITableView alloc]init];
    self.svp_settingTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.svp_settingTableView];
}

- (void)setupsvp_SettingsData {
    [MBProgressManager showLoading];
    [SVPNetworkCilent svp_setupSettingInfoSuccess:^(SVPSettingModel * _Nonnull svp_model) {
        [MBProgressManager hideAlert];
        self.svp_settingModel = svp_model;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.svp_settingTableView reloadData];
        });
        } fail:^(NSError * _Nonnull error, id  _Nullable response) {
            [MBProgressManager hideAlert];
//            [MBProgressManager showWaitingWithTitle:NSLocalizedString(@"PleaseCheckYourNetwork", nil)];
        }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *svp_cell = [tableView dequeueReusableCellWithIdentifier:@"settingCell"];
    if (svp_cell == nil) {
        svp_cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"settingCell"];
        svp_cell.contentView.backgroundColor = [UIColor whiteColor];
        svp_cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    svp_cell.textLabel.textColor = [UIColor blackColor];
    svp_cell.textLabel.font = [UIFont systemFontOfSize:21.0f];
    if (indexPath.row == 0) {
        svp_cell.textLabel.text = NSLocalizedString(@"VIPVariety", nil);
        svp_cell.detailTextLabel.textColor = [UIColor colorWithRed:24.0/255.0 green:189.0/255.0 blue:241.0/255.0 alpha:1.00];
//        svp_cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",self.svp_settingModel.svp_productNameString];
        svp_cell.detailTextLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"SVP_USERID"];
    }else if (indexPath.row == 1) {
        svp_cell.textLabel.text = NSLocalizedString(@"ExpireDate", nil);
        svp_cell.detailTextLabel.textColor = [UIColor colorWithRed:24.0/255.0 green:189.0/255.0 blue:241.0/255.0 alpha:1.00];
//        svp_cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",self.svp_settingModel.svp_expirtTimeString];
        svp_cell.detailTextLabel.text = self.expireDate;
    }
//    else if (indexPath.row == 2) {
//        svp_cell.textLabel.text = NSLocalizedString(@"PurchaseRecord", nil);
//        svp_cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    }else if (indexPath.row == 3) {
//        svp_cell.textLabel.text = NSLocalizedString(@"MessageCenter", nil);
//        svp_cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    }
    else if (indexPath.row == 2) {
        svp_cell.textLabel.text = NSLocalizedString(@"RateUs", nil);
        svp_cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return svp_cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row == 2) {
//        SVPPurchaseHistoryViewController *svp_purchaseHistoryVC = [[SVPPurchaseHistoryViewController alloc]init];
//        svp_purchaseHistoryVC.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:svp_purchaseHistoryVC animated:YES];
//    }else if (indexPath.row == 3) {
//        SVPMessageCenterViewController *svp_messageVC = [[SVPMessageCenterViewController alloc]init];
//        svp_messageVC.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:svp_messageVC animated:YES];
//    }else if (indexPath.row == 4) {
//
//    }
    if (indexPath.row == 2) {
        NSString* urlString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?action=write-review", @"1585952057"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
    }
}
@end
