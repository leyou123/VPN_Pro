//
//  SVPLinesTableViewCell.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/18.
//

#import "SVPLinesTableViewCell.h"
#import "SVPLocalDataTool.h"
#import "SVPSizeUtils.h"

@implementation SVPLinesTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupLineCellUI];
    }
    return self;
}

- (void)setupLineCellUI {
    self.svp_linesCountryImageView = [[UIImageView alloc]init];
    self.svp_linesCountryImageView.frame = CGRectMake(15, 12, 36, 36);
    self.svp_linesCountryImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.svp_linesCountryImageView];
    
    self.svp_lineNameLabel = [[UILabel alloc]init];
    self.svp_lineNameLabel.frame = CGRectMake(60, 12, [SVPSizeUtils svp_width]/2.2, 36);
    self.svp_lineNameLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.svp_lineNameLabel];
    
    NSString *svp_status = [SVPLocalDataTool objectForKey:@"server_delay_type"];
    if ([svp_status integerValue] == 0) {
        self.svp_lineDelayLabel = [[UILabel alloc]init];
        self.svp_lineDelayLabel.frame = CGRectMake([SVPSizeUtils svp_width] - 60, 17, 50, 26);
        self.svp_lineDelayLabel.textColor = [UIColor blackColor];
        self.svp_lineDelayLabel.layer.cornerRadius = 5;
        self.svp_lineDelayLabel.layer.masksToBounds = YES;
        self.svp_lineDelayLabel.textAlignment = NSTextAlignmentCenter;
        self.svp_lineDelayLabel.font = [UIFont systemFontOfSize:13.0];
        self.svp_lineDelayLabel.hidden = YES;
        [self.contentView addSubview:self.svp_lineDelayLabel];
    }else {
        self.svp_delayView = [[UIView alloc]init];
        self.svp_delayView.layer.cornerRadius = 7.5;
        self.svp_delayView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.svp_delayView];
    }
    
    self.svp_lineRecommendLabel = [[UILabel alloc]init];
    self.svp_lineRecommendLabel.frame = CGRectMake([SVPSizeUtils svp_width] - 130, 17, 60, 26);
    self.svp_lineRecommendLabel.textColor = [UIColor blackColor];
    self.svp_lineRecommendLabel.layer.cornerRadius = 5;
    self.svp_lineRecommendLabel.layer.masksToBounds = YES;
    self.svp_lineRecommendLabel.textAlignment = NSTextAlignmentCenter;
    self.svp_lineRecommendLabel.font = [UIFont systemFontOfSize:13.5];
    [self.contentView addSubview:self.svp_lineRecommendLabel];
}
@end
