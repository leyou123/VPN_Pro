//
//  SVPStoreViewController.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/8.
//

#import "SVPStoreViewController.h"
#import "SVPSizeUtils.h"
#import "SVPDeviceUtils.h"
#import "MBProgressManager.h"
#import "SVPPurchaseDescriptionViewController.h"
#import "SVPInterfaceManager.h"
#import "SVPNetworkCilent.h"
#import "SVPIapHelper.h"
#import "SVPLocalDataTool.h"
#import "SVPDateUtils.h"

@interface SVPStoreViewController ()
@property (nonatomic, strong)UILabel *svp_productsLabel;
@property (nonatomic, strong)UIScrollView *svp_PurchaseScrollView;
@property (nonatomic, strong)UIImageView *svp_purchaseDesImageView;

@property (nonatomic, strong)UILabel *svp_productsLabel30;
@property (nonatomic, strong)UILabel *svp_productsLabel90;
@property (nonatomic, strong)UILabel *svp_productsLabel180;
@property (nonatomic, strong)UILabel *svp_productsLabel360;
@property (nonatomic, strong)NSDictionary *svp_storeDic;
@property (nonatomic, strong)NSMutableArray *svp_storeDataArray;
@property (nonatomic, strong)NSString *svp_orderNumber;
@property (nonatomic, strong)NSString *svp_transactionID;
@property (nonatomic, strong)NSString *svp_productID;
@end

@implementation SVPStoreViewController

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.svp_storeDataArray = [[NSMutableArray alloc]init];
    [self setup_svpPurchaseUI];
    [self setup_svpProductsData];
    
    
    SVPPurchaseDescriptionViewController *svp_PurchaseDescriptionVC = [[SVPPurchaseDescriptionViewController alloc]init];
    svp_PurchaseDescriptionVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:svp_PurchaseDescriptionVC animated:YES completion:nil];
}

- (void)setup_svpProductsData {
    [MBProgressManager showLoading];
    NSString *svp_pathString = @"/v1/product_list";
    NSString *svp_tag;
    if ([SVPDeviceUtils svp_getNeedStill]) {
        svp_tag = [SVPDeviceUtils svp_getAuthorization];
    }else {
        svp_tag = @"";
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:svp_tag forKey:@"tag"];
    
    
    NSDictionary * dic1 = @{@"display_amount":@"30",@"product_id":@"com.superpro.30"};
    NSDictionary * dic2 = @{@"display_amount":@"90",@"product_id":@"com.superpro.90"};
    NSDictionary * dic3 = @{@"display_amount":@"180",@"product_id":@"com.superpro.180"};
    NSDictionary * dic4 = @{@"display_amount":@"360",@"product_id":@"com.superpro.360"};
    [self.svp_storeDataArray addObject:dic1];
    [self.svp_storeDataArray addObject:dic2];
    [self.svp_storeDataArray addObject:dic3];
    [self.svp_storeDataArray addObject:dic4];
    [MBProgressManager hideAlert];
    [self setup_svpProductsUI];
    
    
    [SVPInterfaceManager svp_get:svp_pathString withParams:dic success:^(id  _Nullable response) {
    
        self.svp_storeDic = (NSDictionary*)response;
        [self.svp_storeDataArray addObjectsFromArray:[self.svp_storeDic objectForKey:@"data"]];
        [MBProgressManager hideAlert];
        [self setup_svpProductsUI];
        } failure:^(NSError * _Nonnull error, id  _Nullable response) {
            
        }];
}

- (void)setup_svpPurchaseUI {
    _svp_PurchaseScrollView = [[UIScrollView alloc]init];
    _svp_PurchaseScrollView.frame = CGRectMake(0, 0, [SVPSizeUtils svp_width], [SVPSizeUtils svp_height]);
    _svp_PurchaseScrollView.backgroundColor = [UIColor clearColor];
    _svp_PurchaseScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    _svp_PurchaseScrollView.showsVerticalScrollIndicator = NO;
    _svp_PurchaseScrollView.contentSize = CGSizeMake([SVPSizeUtils svp_width], [SVPSizeUtils svp_height]+55);
    _svp_PurchaseScrollView.contentInset = UIEdgeInsetsMake(0, 0, -50, 0);
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view addSubview:_svp_PurchaseScrollView];
    
    _svp_purchaseDesImageView = [[UIImageView alloc]init];
    _svp_purchaseDesImageView.frame = CGRectMake(15, [SVPSizeUtils svp_statusFrameHeight] + 10, [SVPSizeUtils svp_width] - 30, 686/2);
    _svp_purchaseDesImageView.image = [UIImage imageNamed:@"purchase_desTopImg"];
    [_svp_PurchaseScrollView addSubview:_svp_purchaseDesImageView];
    
    UILabel * svp_topTitleLabel = [[UILabel alloc]init];
    svp_topTitleLabel.frame = CGRectMake(30, 64, [SVPSizeUtils svp_width] - 60, 21);
    svp_topTitleLabel.textColor = [UIColor whiteColor];
    svp_topTitleLabel.font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:27];
    svp_topTitleLabel.text = @"Join the VIP";
    [_svp_PurchaseScrollView addSubview:svp_topTitleLabel];
    UILabel * svp_topLittileTitleLabel = [[UILabel alloc]init];
    svp_topLittileTitleLabel.frame = CGRectMake(svp_topTitleLabel.frame.origin.x, svp_topTitleLabel.frame.origin.y + svp_topTitleLabel.frame.size.height + 5, [SVPSizeUtils svp_width] - 60, 21);
    svp_topLittileTitleLabel.textColor = [UIColor whiteColor];
    svp_topLittileTitleLabel.font = [UIFont fontWithName:@"Helvetica-Oblique" size:17];
    svp_topLittileTitleLabel.text = @"Feel the Extraordinary Speed";
    [_svp_PurchaseScrollView addSubview:svp_topLittileTitleLabel];
    
    UILabel *svp_desFirstLabel = [[UILabel alloc]init];
    svp_desFirstLabel.frame = CGRectMake(30, svp_topLittileTitleLabel.frame.origin.y + svp_topLittileTitleLabel.frame.size.height + 90, [SVPSizeUtils svp_width] - 65, 21);
    svp_desFirstLabel.textColor = [UIColor whiteColor];
    svp_desFirstLabel.font = [UIFont fontWithName:@"Helvetica-Oblique" size:15];
    svp_desFirstLabel.text = @"Access All Source You Want";
    svp_desFirstLabel.textAlignment = NSTextAlignmentRight;
    [_svp_PurchaseScrollView addSubview:svp_desFirstLabel];
    
    UILabel *svp_desSecondLabel = [[UILabel alloc]init];
    svp_desSecondLabel.frame = CGRectMake(30, svp_desFirstLabel.frame.origin.y + svp_desFirstLabel.frame.size.height + 10, [SVPSizeUtils svp_width] - 60, 21);
    svp_desSecondLabel.textColor = [UIColor whiteColor];
    svp_desSecondLabel.font = [UIFont fontWithName:@"Helvetica-Oblique" size:15];
    svp_desSecondLabel.text = @"One VIP For Multiple Devices";
    svp_desSecondLabel.textAlignment = NSTextAlignmentRight;
    [_svp_PurchaseScrollView addSubview:svp_desSecondLabel];
    
    UILabel *svp_desThirdLabel = [[UILabel alloc]init];
    svp_desThirdLabel.frame = CGRectMake(30, svp_desSecondLabel.frame.origin.y + svp_desSecondLabel.frame.size.height + 10, [SVPSizeUtils svp_width] - 70, 21);
    svp_desThirdLabel.textColor = [UIColor whiteColor];
    svp_desThirdLabel.font = [UIFont fontWithName:@"Helvetica-Oblique" size:15];
    svp_desThirdLabel.text = @"Enjou HD Video Experience    ";
    svp_desThirdLabel.textAlignment = NSTextAlignmentRight;
    [_svp_PurchaseScrollView addSubview:svp_desThirdLabel];
    
    UIButton *svp_restoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    svp_restoreButton.frame = CGRectMake([SVPSizeUtils svp_width] - 30 - 100, svp_desThirdLabel.frame.origin.y + svp_desThirdLabel.frame.size.height + 10, 100, 27);
    [svp_restoreButton setBackgroundImage:[UIImage imageNamed:@"purchase_restoreImg"] forState:UIControlStateNormal];
    [svp_restoreButton addTarget:self action:@selector(svp_restoreAction) forControlEvents:UIControlEventTouchUpInside];
    [_svp_PurchaseScrollView addSubview:svp_restoreButton];
    
    UIButton *svp_instuctionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    svp_instuctionButton.frame = CGRectMake([SVPSizeUtils svp_width] - 30 - 100 - 15 - 100, svp_desThirdLabel.frame.origin.y + svp_desThirdLabel.frame.size.height + 10, 100, 27);
    [svp_instuctionButton setBackgroundImage:[UIImage imageNamed:@"purchase_instuctionImg"] forState:UIControlStateNormal];
    [svp_instuctionButton addTarget:self action:@selector(svp_instuctionButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_svp_PurchaseScrollView addSubview:svp_instuctionButton];
}

- (void)setup_svpProductsUI {
    NSArray *svp_dayArray = @[@"30",@"90",@"180",@"360"];
    
    CGFloat marginX = 15;
    CGFloat top = _svp_purchaseDesImageView.frame.origin.y + _svp_purchaseDesImageView.frame.size.height + 45;
    CGFloat viewHight = 161/2;
    CGFloat width = ([SVPSizeUtils svp_width] - 45)/ 2;//把空隙也算上 15 - 15 - 15 左中右 各间隔15
    NSInteger maxCol = 2;
    for (NSInteger i = 0; i < svp_dayArray.count; i++) {
        NSInteger col = i % maxCol;
        NSInteger row = i / maxCol;
        UIView *svp_productsView = [[UIView alloc]init];
       svp_productsView.frame = CGRectMake(marginX + col * (width + marginX), top + row * (viewHight + marginX), width, viewHight);
        svp_productsView.tag = i;
        svp_productsView.backgroundColor = [UIColor clearColor];
        [_svp_PurchaseScrollView addSubview:svp_productsView];
        UIImageView *svp_productsImageView = [[UIImageView alloc]init];
        svp_productsImageView.frame = CGRectMake(0, 0, svp_productsView.frame.size.width, svp_productsView.frame.size.height);
        svp_productsImageView.image = [UIImage imageNamed:@"purchse_productsBgImg"];
        [svp_productsView addSubview:svp_productsImageView];
        
        UILabel *svp_dayLabel = [[UILabel alloc]init];
        svp_dayLabel.frame = CGRectMake(15, 15, 50, 21);
        svp_dayLabel.textColor = [UIColor whiteColor];
        svp_dayLabel.textAlignment = NSTextAlignmentLeft;
        svp_dayLabel.font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:23];
        svp_dayLabel.text = svp_dayArray[i];
        [svp_productsView addSubview:svp_dayLabel];
        if (i == 0) {
            self.svp_productsLabel30 = [[UILabel alloc]init];
            self.svp_productsLabel30.frame = CGRectMake(width - 10 - 43, viewHight/2 - 30/2, 43, 30);
            self.svp_productsLabel30.textColor = [UIColor colorWithRed:24/255.0 green:189/255.0 blue:241/255.0 alpha:1.00];
            self.svp_productsLabel30.backgroundColor = [UIColor whiteColor];
            self.svp_productsLabel30.text = [self.svp_storeDataArray[i]objectForKey:@"display_amount"];
            self.svp_productsLabel30.textAlignment = NSTextAlignmentCenter;
            self.svp_productsLabel30.font = [UIFont fontWithName:@"Helvetica-Oblique" size:12.5];
            [svp_productsView addSubview:self.svp_productsLabel30];
        }else if (i == 1){
            self.svp_productsLabel90 = [[UILabel alloc]init];
            self.svp_productsLabel90.frame = CGRectMake(width - 10 - 43, viewHight/2 - 30/2, 43, 30);
            self.svp_productsLabel90.textColor = [UIColor colorWithRed:24/255.0 green:189/255.0 blue:241/255.0 alpha:1.00];
            self.svp_productsLabel90.backgroundColor = [UIColor whiteColor];
            self.svp_productsLabel90.text = [self.svp_storeDataArray[i]objectForKey:@"display_amount"];
            self.svp_productsLabel90.textAlignment = NSTextAlignmentCenter;
            self.svp_productsLabel90.font = [UIFont fontWithName:@"Helvetica-Oblique" size:12.5];
            [svp_productsView addSubview:self.svp_productsLabel90];
        }else if (i == 2){
            self.svp_productsLabel180 = [[UILabel alloc]init];
            self.svp_productsLabel180.frame = CGRectMake(width - 10 - 43, viewHight/2 - 30/2, 43, 30);
            self.svp_productsLabel180.textColor = [UIColor colorWithRed:24/255.0 green:189/255.0 blue:241/255.0 alpha:1.00];
            self.svp_productsLabel180.backgroundColor = [UIColor whiteColor];
            self.svp_productsLabel180.text = [self.svp_storeDataArray[i]objectForKey:@"display_amount"];
            self.svp_productsLabel180.textAlignment = NSTextAlignmentCenter;
            self.svp_productsLabel180.font = [UIFont fontWithName:@"Helvetica-Oblique" size:12.5];
            [svp_productsView addSubview:self.svp_productsLabel180];
        }else if (i == 3){
            self.svp_productsLabel360 = [[UILabel alloc]init];
            self.svp_productsLabel360.frame = CGRectMake(width - 10 - 43, viewHight/2 - 30/2, 43, 30);
            self.svp_productsLabel360.textColor = [UIColor colorWithRed:24/255.0 green:189/255.0 blue:241/255.0 alpha:1.00];
            self.svp_productsLabel360.backgroundColor = [UIColor whiteColor];
            self.svp_productsLabel360.text = [self.svp_storeDataArray[i]objectForKey:@"display_amount"];
            self.svp_productsLabel360.textAlignment = NSTextAlignmentCenter;
            self.svp_productsLabel360.font = [UIFont fontWithName:@"Helvetica-Oblique" size:12.5];
            [svp_productsView addSubview:self.svp_productsLabel360];
        }
        
        UIButton *svp_productButton = [UIButton buttonWithType:UIButtonTypeCustom];
        svp_productButton.frame = CGRectMake(0, 0, svp_productsView.frame.size.width, svp_productsView.frame.size.height);
        svp_productButton.backgroundColor = [UIColor clearColor];
        svp_productButton.tag = i;
        [svp_productButton addTarget:self action:@selector(svp_ProductsButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [svp_productsView addSubview:svp_productButton];
    }
}

- (UIColor *)svp_normalColor {
    return [UIColor colorWithRed:24/255.0 green:189/255.0 blue:241/255.0 alpha:1.00];
}

- (UIColor *)svp_selectedColor {
    return [UIColor colorWithRed:255.0/255.0 green:149/255.0 blue:0/255.0 alpha:1.00];
}


- (void)svp_ProductsButtonClick:(UIButton *)sender {
    NSLog(@"%ld",sender.tag);
    if (sender.tag == 0) {
        self.svp_productID = [self.svp_storeDataArray[0]objectForKey:@"product_id"];
        self.svp_productsLabel30.textColor = [self svp_selectedColor];
        self.svp_productsLabel90.textColor = [self svp_normalColor];
        self.svp_productsLabel180.textColor =[self svp_normalColor];
        self.svp_productsLabel360.textColor = [self svp_normalColor];
    }else if (sender.tag == 1){
        self.svp_productID = [self.svp_storeDataArray[1]objectForKey:@"product_id"];
        self.svp_productsLabel30.textColor = [self svp_normalColor];
        self.svp_productsLabel90.textColor = [self svp_selectedColor];
        self.svp_productsLabel180.textColor =[self svp_normalColor];
        self.svp_productsLabel360.textColor = [self svp_normalColor];
    }else if (sender.tag == 2){
        self.svp_productID = [self.svp_storeDataArray[2]objectForKey:@"product_id"];
        self.svp_productsLabel30.textColor = [self svp_normalColor];
        self.svp_productsLabel90.textColor = [self svp_normalColor];
        self.svp_productsLabel180.textColor =[self svp_selectedColor];
        self.svp_productsLabel360.textColor = [self svp_normalColor];
    }else if (sender.tag == 3){
        self.svp_productID = [self.svp_storeDataArray[3]objectForKey:@"product_id"];
        self.svp_productsLabel30.textColor = [self svp_normalColor];
        self.svp_productsLabel90.textColor = [self svp_normalColor];
        self.svp_productsLabel180.textColor =[self svp_normalColor];
        self.svp_productsLabel360.textColor = [self svp_selectedColor];
    }
    
    [self svp_purchaseWithProductID:self.svp_productID];
}

#pragma mark - purchase
- (void)svp_purchaseWithProductID:(NSString *)svp_ID {
    [MBProgressManager showLoading];
    [SVPIapHelper svp_purchase:svp_ID onCompletion:^(BOOL success, SKPaymentTransaction * _Nonnull transcation) {
        if (success) {
            [MBProgressManager hideAlert];
            self.svp_transactionID = transcation.transactionIdentifier;
            NSData *svp_receipt = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
            NSLog(@"%@",svp_receipt);
            [SVPIapHelper svp_checkReceiptWithShareSecret:@"4c77e8edfe904353a4310fefd55a19a4" sandBoxMode:YES onCompletion:^(NSDictionary * _Nonnull result) {
                [SVPLocalDataTool setObject:result forKey:@"ticketInformation"];
                [self svp_setupLocalOrderWith:svp_ID];
                NSInteger time = [SVPDateUtils getTimeInterval:svp_ID];
                [SVPDateUtils saveExpireWithInterval:time];
            }];
        }else {
            [MBProgressManager hideAlert];
            if (!transcation) {
                [MBProgressManager showBriefAlert:NSLocalizedString(@"InvalidItem", nil) time:2];
            }
        }
    }];
}

- (void)svp_setupLocalOrderWith:(NSString *)svp_ID {
    NSString *svp_path = @"/v1/order/create";
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:svp_ID forKey:@"product_id"];
    [dic setObject:@"4" forKey:@"pay_type"];
    [SVPInterfaceManager svp_post:svp_path withParams:dic success:^(id  _Nullable response) {
        NSDictionary *svp_resultDic = (NSDictionary *)response;
        self.svp_orderNumber = [[svp_resultDic objectForKey:@"data"]objectForKey:@"order_no"];
        [SVPLocalDataTool setObject:[SVPIapHelper svp_base64receipt] forKey:@"receipt"];
        [self svp_setupLocalOrderVerifyWith:self.svp_transactionID receipt:[SVPIapHelper svp_base64receipt] productID:svp_ID];
        } failure:^(NSError * _Nonnull error, id  _Nullable response) {
            
        }];
}

- (void)svp_setupLocalOrderVerifyWith:(NSString *)svp_transactionID receipt:(NSString *)svp_receipt productID:(NSString *)svp_ID{
    NSString *svp_path = @"/v1/order/verify/apple";
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[SVPDeviceUtils getIDFA] forKey:@"idfa"];
    [dic setObject:svp_ID forKey:@"product_id"];
    [dic setObject:svp_receipt forKey:@"receipt"];
    [dic setObject:self.svp_orderNumber forKey:@"order_no"];
    [dic setObject:svp_transactionID forKey:@"third_pay_trade_no"];
    [SVPInterfaceManager svp_post:svp_path withParams:dic success:^(id  _Nullable response) {
        [self svp_setupUserVIPLimit];
        } failure:^(NSError * _Nonnull error, id  _Nullable response) {
            
        }];
}

- (void)svp_setupUserVIPLimit {
    NSString *svp_path = @"/v1/account/limit";
    [SVPInterfaceManager svp_post:svp_path withParams:nil success:^(id  _Nullable response) {
            
        } failure:^(NSError * _Nonnull error, id  _Nullable response) {
            
        }];
}

- (void)svp_restoreAction {
    NSString *svp_receipt = [SVPLocalDataTool objectForKey:@"receipt"];
    if (svp_receipt == nil) {
        svp_receipt = @"";
    }
    
    [SVPIapHelper svp_restorePurchase:^(SKPaymentQueue * _Nonnull payment, NSError * _Nonnull error) {
        if (error) {
            [MBProgressManager showBriefAlert:@"check order error" time:2.0];
        }else {
            [MBProgressManager showBriefAlert:@"check order success" time:2.0];
        }
    }];
        NSString *path = @"/v1/order/restore/apple";
        NSDictionary *params = @{
                                 @"idfa":[SVPDeviceUtils getIDFA],
                                 @"receipt":svp_receipt,
                                 };
        [SVPInterfaceManager svp_post:path withParams:params success:^(id  _Nullable response) {
            NSLog(@"恢复购买 %@",response);
            [MBProgressManager showBriefAlert:@"check order success" time:2.0];
        } failure:^(NSError * _Nonnull error,id  _Nullable response) {
            NSLog(@"error:%@",error);
            [MBProgressManager showBriefAlert:@"request for order fail" time:2.0];
        }];
}

- (void)svp_instuctionButtonAction {
    SVPPurchaseDescriptionViewController *svp_instructionVC = [[SVPPurchaseDescriptionViewController alloc]init];
    svp_instructionVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:svp_instructionVC animated:YES completion:nil];
}
@end
