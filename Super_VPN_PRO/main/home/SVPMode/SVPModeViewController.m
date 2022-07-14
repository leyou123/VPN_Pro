//
//  SVPModeViewController.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/18.
//

#import "SVPModeViewController.h"
#import "SVPModeTableViewCell.h"
#import "SVPSizeUtils.h"

@interface SVPModeViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView *modeTableView;
@property (nonatomic,strong)NSIndexPath *indexPathNeedsSelect;

@end

@implementation SVPModeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self svp_setupModeUI];
}

- (void)svp_setupModeUI {
    UIImageView *svp_topBgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [SVPSizeUtils svp_width], [SVPSizeUtils svp_statusFrameHeight]+self.navigationController.navigationBar.frame.size.height)];
    svp_topBgImageView.image = [UIImage imageNamed:@"main_topBg"];
    [self.view addSubview:svp_topBgImageView];
    
    UIButton *svp_BackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [svp_BackButton setBackgroundColor:[UIColor clearColor]];
    svp_BackButton.frame = CGRectMake(15,[SVPSizeUtils svp_statusFrameHeight] + 10, 20, 25);
    [svp_BackButton setImage:[UIImage imageNamed:@"svp_backButton"] forState:UIControlStateNormal];
    [svp_BackButton addTarget:self action:@selector(svp_BackAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:svp_BackButton];
    
    self.modeTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,self.navigationController.navigationBar.frame.size.height + [SVPSizeUtils svp_statusFrameHeight],[SVPSizeUtils svp_width], [SVPSizeUtils svp_height] - self.navigationController.navigationBar.frame.size.height - [SVPSizeUtils svp_statusFrameHeight]) style:UITableViewStylePlain];
    self.modeTableView.delegate = self;
    self.modeTableView.dataSource = self;
    self.modeTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.modeTableView.tableFooterView = [[UITableView alloc]init];
    self.modeTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.modeTableView];
}

- (void)svp_BackAction {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UItableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 155;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SVPModeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[SVPModeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    NSArray *titleArray = @[NSLocalizedString(@"protocolA1", nil),NSLocalizedString(@"protocolB1", nil),NSLocalizedString(@"protocolC1", nil)];

    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.backgroundColor = [UIColor clearColor];
    cell.svp_modeSelectedImageView.image = [UIImage imageNamed:@"protocol_normal"];

    //没有的话默认ss 其他的记录
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *statusString = [userDefaults objectForKey:@"selected"];
    if (statusString) {
        if (indexPath.row == [statusString integerValue]) {
            // 自动选中某行，调用[cell setSelected:]
            [tableView selectRowAtIndexPath:indexPath animated:false scrollPosition:UITableViewScrollPositionNone];
            cell.svp_modeSelectedImageView.image = [UIImage imageNamed:@"protocol_selected"];
        }
    }else{
        if (indexPath.row == 0) {
            // 自动选中某行，调用[cell setSelected:]
            [tableView selectRowAtIndexPath:indexPath animated:false scrollPosition:UITableViewScrollPositionNone];
            cell.svp_modeSelectedImageView.image = [UIImage imageNamed:@"protocol_selected"];
        }
    }
    
    cell.svp_modeTitleLabel.text = [titleArray objectAtIndex:indexPath.row];
    NSArray *starArrayA = @[@"protocol_AAA",@"protocol_AAA",@"protocol_BBB",@"protocol_AAA"];
    NSArray *starArrayB = @[@"protocol_CCC",@"protocol_BBB",@"protocol_AAA",@"protocol_BBB"];
    NSArray *starArrayC = @[@"protocol_CCC",@"protocol_BBB",@"protocol_BBB",@"protocol_BBB"];
    
    if (indexPath.row == 0) {
        for (int i = 0; i < 4; i++) {
            UIImageView *starImageA = [[UIImageView alloc]initWithFrame:CGRectMake([SVPSizeUtils svp_width] - [SVPSizeUtils svp_width] / 2.9 - 20, 49 + 25 *i, [SVPSizeUtils svp_width] / 2.9, 15)];
            starImageA.backgroundColor = [UIColor clearColor];
            starImageA.image = [UIImage imageNamed:[starArrayA objectAtIndex:i]];
            [cell addSubview:starImageA];
        }
    }
    if (indexPath.row == 1) {
        for (int i = 0; i < 4; i++) {
            UIImageView *starImageA = [[UIImageView alloc]initWithFrame:CGRectMake([SVPSizeUtils svp_width] - [SVPSizeUtils svp_width] / 2.9 - 20, 49 + 25 *i, [SVPSizeUtils svp_width] / 2.9, 15)];
            starImageA.backgroundColor = [UIColor clearColor];
            starImageA.image = [UIImage imageNamed:[starArrayB objectAtIndex:i]];
            [cell addSubview:starImageA];
        }
    }
    if (indexPath.row == 2) {
        for (int i = 0; i < 4; i++) {
            UIImageView *starImageA = [[UIImageView alloc]initWithFrame:CGRectMake([SVPSizeUtils svp_width] - [SVPSizeUtils svp_width] / 2.9 - 20, 49 + 25 *i, [SVPSizeUtils svp_width] / 2.9, 15)];
            starImageA.backgroundColor = [UIColor clearColor];
            starImageA.image = [UIImage imageNamed:[starArrayC objectAtIndex:i]];
            [cell addSubview:starImageA];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSUserDefaults *incentives = [NSUserDefaults standardUserDefaults];
    [incentives setObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row] forKey:@"selected"];
    [incentives synchronize];
    
    SVPModeTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:true];
    _indexPathNeedsSelect = indexPath;
    cell.svp_modeSelectedImageView.image = [UIImage imageNamed:@"protocol_selected"];
    NSLog(@"----%@",tableView.visibleCells);
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    SVPModeTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:false];
    cell.svp_modeSelectedImageView.image = [UIImage imageNamed:@"protocol_normal"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 80;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *svp_ProtocolIntroduceView = [[UIView alloc] init];
    svp_ProtocolIntroduceView.backgroundColor = [UIColor whiteColor];
    
    UILabel *svp_IntroduceLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, 15, [UIScreen mainScreen].bounds.size.width - 50, 55)];
    svp_IntroduceLabel.numberOfLines = 0;
    svp_IntroduceLabel.textColor = [UIColor colorWithRed:24.0/255.0 green:189.0/255.0 blue:241.0/255.0 alpha:1.00];
    svp_IntroduceLabel.font= [UIFont fontWithName:@"Helvetica-Oblique" size:15.0];
    svp_IntroduceLabel.text = @"To protect your privacy and according to regional laws and regulations, we will use A,B,C instead of the real protocol name ";
    [svp_ProtocolIntroduceView addSubview:svp_IntroduceLabel];
    
    return svp_ProtocolIntroduceView ;
}
@end
