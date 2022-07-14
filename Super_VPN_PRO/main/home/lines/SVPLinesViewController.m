//
//  SVPLinesViewController.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/18.
//

#import "SVPLinesViewController.h"
#import "SVPLinesTableViewCell.h"
#import "SVPLocalDataTool.h"
#import "SVPNetworkCheckManager.h"
#import "SVPSizeUtils.h"
#import "SVPDeviceUtils.h"
#import "SVPServerConnection.h"
#import "SVPInterfaceManager.h"
#import "SVPDes.h"
#import "SVPPingServices.h"
#import "MBProgressManager.h"
#import "SVPNetworkCilent.h"
#import "UIImageView+WebCache.h"

@interface SVPLinesViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic)UITableView *svp_linesTableView;
@property (strong, nonatomic)UILabel *svp_noDataLabel;
@property (strong, nonatomic)SVPServerConnection *svp_connection;

@property (strong, nonatomic)NSMutableArray *svp_VIPLinesArray;
@property (strong, nonatomic)NSMutableArray *svp_FreeLinesArray;
@property (strong, nonatomic)NSMutableDictionary *svp_pingServiceDictionary;
@end

@implementation SVPLinesViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.svp_FreeLinesArray = [[NSMutableArray alloc]init];
    self.svp_VIPLinesArray = [[NSMutableArray alloc]init];
    self.svp_pingServiceDictionary = [NSMutableDictionary dictionary];
    [self setup_svpLineForVIPService:@"0"];
    [self setup_SVPLinesUI];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    for (NSString *key in self.svp_pingServiceDictionary) {
        SVPPingServices *svp_service = self.svp_pingServiceDictionary[key];
        [svp_service cancel];
    }
}

- (void)setup_svpLineForVIPService:(NSString *)svp_isVIPString {
    [MBProgressManager showLoading];
    NSString *svp_pathString = @"/v1/area";
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"0" forKey:@"is_vip"];
    
    NSArray * arr = [self readLocalFileWithName:@"country"];
    [self.svp_FreeLinesArray addObjectsFromArray:arr];
    
    
    [SVPLocalDataTool setObject:[self.svp_FreeLinesArray[0]objectForKey:@"ping_subnet" ]forKey:@"pingSubnetFree"];
    
    [MBProgressManager hideAlert];
    [self.svp_linesTableView reloadData];
    
    [SVPInterfaceManager svp_post:svp_pathString withParams:dic success:^(id  _Nullable response) {
        NSString *svp_responseString = [response objectForKey:@"data"];
        NSString *svp_resultString = [SVPDes decode:svp_responseString key:[SVPDeviceUtils getDesKeyString]];
        if ([svp_isVIPString integerValue] == 1) {
            self.svp_VIPLinesArray = [SVPDeviceUtils arrayWithJsonString:svp_resultString];
            [SVPLocalDataTool setObject:[self.svp_VIPLinesArray[0]objectForKey:@"ping_subnet" ]forKey:@"pingSubnetVIP"];
        }
        if ([svp_isVIPString integerValue] == 0) {
            self.svp_FreeLinesArray = [SVPDeviceUtils arrayWithJsonString:svp_resultString];
            [SVPLocalDataTool setObject:[self.svp_FreeLinesArray[0]objectForKey:@"ping_subnet" ]forKey:@"pingSubnetFree"];
            
            if(self.svp_FreeLinesArray.count == 0) {
                self.svp_noDataLabel.hidden = NO;
            }
        }
        [MBProgressManager hideAlert];
        [self.svp_linesTableView reloadData];
        } failure:^(NSError * _Nonnull error, id  _Nullable response) {
            NSLog(@"LineForVIPService error:%@",error);
            [MBProgressManager hideAlert];
//            [MBProgressManager showBriefAlert:NSLocalizedString(@"SVP_Anomaly", nil) time:2];
        }];
}

- (void)setup_SVPLinesUI {
    UIImageView *svp_topBgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [SVPSizeUtils svp_width], [SVPSizeUtils svp_statusFrameHeight]+self.navigationController.navigationBar.frame.size.height)];
    svp_topBgImageView.image = [UIImage imageNamed:@"main_topBg"];
    [self.view addSubview:svp_topBgImageView];
    
    UIButton *svp_BackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [svp_BackButton setBackgroundColor:[UIColor clearColor]];
    svp_BackButton.frame = CGRectMake(15,[SVPSizeUtils svp_statusFrameHeight] + 10, 20, 25);
    [svp_BackButton setImage:[UIImage imageNamed:@"svp_backButton"] forState:UIControlStateNormal];
    [svp_BackButton addTarget:self action:@selector(svp_BackAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:svp_BackButton];
    
    UIButton *svp_refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [svp_refreshButton setBackgroundColor:[UIColor clearColor]];
    svp_refreshButton.frame = CGRectMake([SVPSizeUtils svp_width]- 15 - 20,[SVPSizeUtils svp_statusFrameHeight] + 10, 20, 25);
    [svp_refreshButton setImage:[UIImage imageNamed:@"line_refresh"] forState:UIControlStateNormal];
    [svp_refreshButton addTarget:self action:@selector(svp_RefreshAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:svp_refreshButton];
    
    
    self.svp_linesTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,self.navigationController.navigationBar.frame.size.height + [SVPSizeUtils svp_statusFrameHeight],[SVPSizeUtils svp_width], [SVPSizeUtils svp_height] - self.navigationController.navigationBar.frame.size.height - [SVPSizeUtils svp_statusFrameHeight]) style:UITableViewStylePlain];
    self.svp_linesTableView.delegate = self;
    self.svp_linesTableView.dataSource = self;
    self.svp_linesTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.svp_linesTableView.tableFooterView = [[UITableView alloc]init];
    self.svp_linesTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.svp_linesTableView];
    
    self.svp_noDataLabel = [[UILabel alloc]init];
    self.svp_noDataLabel.frame = CGRectMake(0, [SVPSizeUtils svp_height]/2, [SVPSizeUtils svp_width], 21);
    self.svp_noDataLabel.text = @"No lines Data";
    self.svp_noDataLabel.textAlignment = NSTextAlignmentCenter;
    self.svp_noDataLabel.textColor = [UIColor blackColor];
    self.svp_noDataLabel.font = [UIFont systemFontOfSize:17.0];
    self.svp_noDataLabel.hidden = YES;
    [self.view addSubview:self.svp_noDataLabel];
}

- (void)svp_BackAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)svp_RefreshAction {
    [self setup_svpLineForVIPService:@"0"];
    for (NSString *key in self.svp_pingServiceDictionary) {
        SVPPingServices *svp_service = self.svp_pingServiceDictionary[key];
        [svp_service cancel];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.svp_FreeLinesArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SVPLinesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[SVPLinesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    
    cell.svp_lineNameLabel.text = [self.svp_FreeLinesArray[indexPath.row]objectForKey:@"name"];
    if ([[self.svp_FreeLinesArray[indexPath.row]objectForKey:@"status"] isEqualToString:@"2"]) {
        cell.svp_lineRecommendLabel.text = [self.svp_FreeLinesArray[indexPath.row]objectForKey:@"status_name"];
        cell.svp_lineRecommendLabel.backgroundColor = [UIColor colorWithRed:1.00 green:0.35 blue:0.30 alpha:1.00];
    }else{
        if ([self.svp_FreeLinesArray[indexPath.row]objectForKey:@"label"] != nil) {
            cell.svp_lineRecommendLabel.text = [self.svp_FreeLinesArray[indexPath.row]objectForKey:@"label"];
            cell.svp_lineRecommendLabel.backgroundColor = [UIColor greenColor];
            cell.svp_lineRecommendLabel.hidden = YES;
        }else{
            cell.svp_lineRecommendLabel.hidden = YES;
        }
    }
    NSString *svp_lineFlag = [self.svp_FreeLinesArray[indexPath.row]objectForKey:@"flag"];
//    [cell.svp_linesCountryImageView sd_setImageWithURL:[NSURL URLWithString:svp_lineFlag]];
    cell.svp_linesCountryImageView.image = [UIImage imageNamed:svp_lineFlag];
    
    NSString *svp_pingServerAddress = [self.svp_FreeLinesArray[indexPath.row]objectForKey:@"ping_server"];
    if (svp_pingServerAddress!= nil) {
        NSString *key = [NSString stringWithFormat:@"%lu-%lu",indexPath.section, indexPath.row];
        self.svp_pingServiceDictionary[key] = [SVPPingServices svp_startPingAddress:svp_pingServerAddress callbackHandler:^(SVPPingItem * _Nonnull pingItem, NSArray * _Nonnull pingItems) {
            NSString *svp_delayStatus = [SVPLocalDataTool objectForKey:@"server_delay_type"];
            if ([svp_delayStatus integerValue] == 0) {
                if (pingItem.timeMilliseconds > 999) {
                    cell.svp_lineDelayLabel.text = @"999ms";
                    cell.svp_lineDelayLabel.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:89.0/255.0 blue:76/255.0 alpha:1.0];
                }
                if (pingItem.timeMilliseconds >= [[self.svp_FreeLinesArray[indexPath.row]objectForKey:@"delay_warning"] integerValue]){
                    cell.svp_lineDelayLabel.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:89.0/255.0 blue:76/255.0 alpha:1.0];
                    cell.svp_lineDelayLabel.text = [NSString stringWithFormat:@"%.0fms",pingItem.timeMilliseconds];
                }
                
                if (pingItem.timeMilliseconds == 0.000000) {
                    if ([cell.svp_lineDelayLabel.text integerValue] >= [[self.svp_FreeLinesArray[indexPath.row]objectForKey:@"delay_warning"] integerValue]) {
                        cell.svp_lineDelayLabel.text = [NSString stringWithFormat:@"%.0fms",pingItem.timeMilliseconds];
                    }
                    if (cell.svp_lineDelayLabel.text == nil) {
                        cell.svp_lineDelayLabel.text = @"0ms";
                        cell.svp_lineDelayLabel.backgroundColor = [UIColor greenColor];
                    }
                }else{
                    if (pingItem.timeMilliseconds <= [[self.svp_FreeLinesArray[indexPath.row]objectForKey:@"delay_warning"] integerValue]) {
                        cell.svp_lineDelayLabel.text = [NSString stringWithFormat:@"%.0fms",pingItem.timeMilliseconds];
                        cell.svp_lineDelayLabel.backgroundColor = [UIColor greenColor];
                    }
                }
            }else {
                if (pingItem.timeMilliseconds <= 200) {
                    cell.svp_delayView.backgroundColor = [UIColor greenColor];
                }
                if (pingItem.timeMilliseconds >= 200 && pingItem.timeMilliseconds <= 400) {
                    cell.svp_delayView.backgroundColor = [UIColor yellowColor];
                }
                if (pingItem.timeMilliseconds > 400) {
                    cell.svp_delayView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:89.0/255.0 blue:76/255.0 alpha:1.0];
                }
            }
        }];
    }else{
        cell.svp_lineDelayLabel.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self.svp_FreeLinesArray[indexPath.row]objectForKey:@"status"] isEqualToString:@"2"]) {
        [MBProgressManager showBriefAlert:NSLocalizedString(@"lineFull", nil) time:2];
        return;
    }
    NSString *svp_statusString = [SVPLocalDataTool objectForKey:@"noTraffic"];
    svp_statusString = @"1";
    if ([svp_statusString integerValue] == 1) {
            NSString *status = [NSString stringWithFormat:@"%@",[self.svp_FreeLinesArray[indexPath.row]objectForKey:@"status"]];
            if ([status isEqualToString:@"1"]) {
                [SVPLocalDataTool setObject:[self.svp_FreeLinesArray[indexPath.row]objectForKey:@"name"] forKey:@"lineName"];
                if ([self.svp_FreeLinesArray[indexPath.row]objectForKey:@"line"] != nil) {
                    NSData *svp_data = [NSKeyedArchiver archivedDataWithRootObject:[self.svp_FreeLinesArray[indexPath.row]objectForKey:@"line"]];
                    [SVPLocalDataTool setObject:svp_data forKey:@"ConfigurationV"];
                    [SVPLocalDataTool setObject:[self.svp_FreeLinesArray[indexPath.row]objectForKey:@"status"] forKey:@"lineStatus"];
                    
                    [SVPNetworkCilent svp_linesSelectRate: [[self.svp_FreeLinesArray[indexPath.row]objectForKey:@"line"]objectForKey:@"ip"]];
            
                    if ([self.delegate respondsToSelector:@selector(svp_setupLinesSelectedAutoConnect:)]) {
                        [self.delegate svp_setupLinesSelectedAutoConnect:self];
                    }
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }else{
                [MBProgressManager showBriefAlert:NSLocalizedString(@"Maintain", nil) time:2];
            }
    }else{
        if ([self.svp_lineIsVIP integerValue] == 0 && [self.svp_is_trial integerValue] == 0) {
            [MBProgressManager showBriefAlert:NSLocalizedString(@"DataError", nil) time:2];
        }
        if ([self.svp_allow_trial_time integerValue] == 1) {
            [MBProgressManager showBriefAlert:NSLocalizedString(@"TimeOver", nil) time:2];
        }
        if ([self.svp_allow_trial_traffic integerValue] == 1) {
            [MBProgressManager showBriefAlert:NSLocalizedString(@"Exhausted", nil) time:2];
        }
    }
}

- (NSArray *)readLocalFileWithName:(NSString *)name {
    NSString * path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    NSData * data = [[NSData alloc] initWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
}

@end
