//
//  SVPMessageCenterViewController.m
//  Super_VPN_PRO
//
//  Created by SunDaDa on 2021/9/28.
//

#import "SVPMessageCenterViewController.h"
#import "SVPMessageCenterTableViewCell.h"
#import "SVPSizeUtils.h"
#import "SVPDeviceUtils.h"
#import "SVPInterfaceManager.h"

@interface SVPMessageCenterViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic)UITableView *svp_messageTableView;
@property (strong, nonatomic)NSMutableArray *svp_dataArray;
@property (strong, nonatomic)UILabel *svp_noDataLabel;
@end

@implementation SVPMessageCenterViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setup_svpMessageCenterUI];
    [self setup_svpMessageData];
    self.svp_dataArray = [[NSMutableArray alloc]init];
}

- (void)setup_svpMessageCenterUI {
    UIImageView *svp_topBgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [SVPSizeUtils svp_width], [SVPSizeUtils svp_statusFrameHeight]+self.navigationController.navigationBar.frame.size.height)];
    svp_topBgImageView.image = [UIImage imageNamed:@"main_topBg"];
    [self.view addSubview:svp_topBgImageView];
    
    UIButton *svp_BackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [svp_BackButton setBackgroundColor:[UIColor clearColor]];
    svp_BackButton.frame = CGRectMake(15,[SVPSizeUtils svp_statusFrameHeight] + 10, 20, 25);
    [svp_BackButton setImage:[UIImage imageNamed:@"svp_backButton"] forState:UIControlStateNormal];
    [svp_BackButton addTarget:self action:@selector(svp_BackAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:svp_BackButton];
    
    self.svp_messageTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,self.navigationController.navigationBar.frame.size.height + [SVPSizeUtils svp_statusFrameHeight],[SVPSizeUtils svp_width], [SVPSizeUtils svp_height] - self.navigationController.navigationBar.frame.size.height - [SVPSizeUtils svp_statusFrameHeight]) style:UITableViewStylePlain];
    self.svp_messageTableView.delegate = self;
    self.svp_messageTableView.dataSource = self;
    self.svp_messageTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.svp_messageTableView.tableFooterView = [[UITableView alloc]init];
    self.svp_messageTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.svp_messageTableView];
    
    self.svp_noDataLabel = [[UILabel alloc]init];
    self.svp_noDataLabel.frame = CGRectMake(0, [SVPSizeUtils svp_height]/2, [SVPSizeUtils svp_width], 21);
    self.svp_noDataLabel.text = @"No Message Data";
    self.svp_noDataLabel.textAlignment = NSTextAlignmentCenter;
    self.svp_noDataLabel.textColor = [UIColor blackColor];
    self.svp_noDataLabel.font = [UIFont systemFontOfSize:17.0];
    self.svp_noDataLabel.hidden = YES;
    [self.view addSubview:self.svp_noDataLabel];
}

- (void)svp_BackAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setup_svpMessageData {
    NSString *svp_pathString = @"/v1/message";
    NSString *svp_stringTag;
    if ([SVPDeviceUtils svp_getNeedStill]) {
        svp_stringTag = [SVPDeviceUtils svp_getAuthorization];
    }else {
        svp_stringTag = @"";
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[SVPDeviceUtils getBundleVersion] forKey:@"app_version"];
    [dic setObject:svp_stringTag forKey:@"tag"];
    [SVPInterfaceManager svp_get:svp_pathString withParams:dic success:^(id  _Nullable response) {
        NSDictionary *svp_resultDic = (NSDictionary *)response;
        [self.svp_dataArray addObjectsFromArray:[svp_resultDic objectForKey:@"data"]];
        if (self.svp_dataArray.count == 0) {
            self.svp_noDataLabel.hidden = NO;
        }else {
            self.svp_noDataLabel.hidden = YES;
        }
        [self.svp_messageTableView reloadData];
        } failure:^(NSError * _Nonnull error, id  _Nullable response) {
            self.svp_noDataLabel.hidden = NO;
        }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.svp_dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SVPMessageCenterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[SVPMessageCenterTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.svp_messageTitleLabel.text = [self.svp_dataArray[indexPath.row] objectForKey:@"title"];
    cell.svp_timeLabel.text = [self.svp_dataArray[indexPath.row] objectForKey:@"created_at"];
    return cell;
}
@end
