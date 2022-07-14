//
//  SVPPurchaseHistoryViewController.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/29.
//

#import "SVPPurchaseHistoryViewController.h"
#import "SVPPurchaseHistoryTableViewCell.h"
#import "SVPSizeUtils.h"
#import "SVPDeviceUtils.h"
#import "SVPInterfaceManager.h"

@interface SVPPurchaseHistoryViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic)UITableView *svp_messageTableView;
@property (strong, nonatomic)NSMutableArray *svp_dataArray;
@property (strong, nonatomic)UILabel *svp_noDataLabel;

@end

@implementation SVPPurchaseHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.svp_dataArray = [[NSMutableArray alloc]init];
    [self setup_svpPurchaseHistoryData];
    [self setup_svpPurchaseHistoryUI];
}

- (void)setup_svpPurchaseHistoryUI {
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
    self.svp_noDataLabel.text = @"No history data";
    self.svp_noDataLabel.textAlignment = NSTextAlignmentCenter;
    self.svp_noDataLabel.textColor = [UIColor blackColor];
    self.svp_noDataLabel.font = [UIFont systemFontOfSize:17.0];
    self.svp_noDataLabel.hidden = YES;
    [self.view addSubview:self.svp_noDataLabel];
}

- (void)setup_svpPurchaseHistoryData {
    NSString *svp_path = @"/v1/payment_list";
    NSString *svp_stringTag;
    if ([SVPDeviceUtils svp_getNeedStill]) {
        svp_stringTag = [SVPDeviceUtils svp_getAuthorization];
    }else{
        svp_stringTag = @"";
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[SVPDeviceUtils getBundleVersion] forKey:@"app_version"];
    [dic setObject:svp_stringTag forKey:@"tag"];
    [SVPInterfaceManager svp_get:svp_path withParams:dic success:^(id  _Nullable response) {
        NSLog(@"________response%@",response);
        [self.svp_dataArray addObjectsFromArray:[response objectForKey:@"data"]];
        
        if (self.svp_dataArray.count == 0) {
            self.svp_noDataLabel.hidden = NO;
        }
        
        [self.svp_messageTableView reloadData];
        } failure:^(NSError * _Nonnull error, id  _Nullable response) {
            self.svp_noDataLabel.hidden = NO;
        }];
}

- (void)svp_BackAction {
    [self.navigationController popViewControllerAnimated:YES];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.svp_dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SVPSizeUtils svp_width] / 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    SVPPurchaseHistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[SVPPurchaseHistoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    cell.svp_product_name.text = [self.svp_dataArray[indexPath.row] objectForKey:@"product_name"];
    cell.svp_purchase_date.text = [self.svp_dataArray[indexPath.row] objectForKey:@"purchase_date"];
    cell.svp_product_day.text = [self.svp_dataArray[indexPath.row] objectForKey:@"product_day"];
    cell.svp_amount.text = [self.svp_dataArray[indexPath.row]objectForKey:@"amount"];
    return cell;
}

@end
