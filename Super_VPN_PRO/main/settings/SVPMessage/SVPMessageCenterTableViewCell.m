//
//  SVPMessageCenterTableViewCell.m
//  Super_VPN_PRO
//
//  Created by SunDaDa on 2021/9/28.
//

#import "SVPMessageCenterTableViewCell.h"
#import "SVPSizeUtils.h"

@implementation SVPMessageCenterTableViewCell

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
        [self setupMessageCellUI];
    }
    return self;
}

- (void)setupMessageCellUI {
    UIImageView *svp_topImageView = [[UIImageView alloc]init];
    svp_topImageView.frame = CGRectMake(0, 0, [SVPSizeUtils svp_width], 90);
    svp_topImageView.backgroundColor = [UIColor clearColor];
    svp_topImageView.image = [UIImage imageNamed:@"Little"];
    [self.contentView addSubview:svp_topImageView];
    
    UIImageView *svp_leftImageView = [[UIImageView alloc]init];
    svp_leftImageView.frame = CGRectMake(0, 0, [SVPSizeUtils svp_width], 90);
    svp_leftImageView.backgroundColor = [UIColor clearColor];
    svp_leftImageView.image = [UIImage imageNamed:@"main_newsImg"];
    [self.contentView addSubview:svp_leftImageView];
    
    self.svp_messageTitleLabel = [[UILabel alloc]init];
    self.svp_messageTitleLabel.frame = CGRectMake(60, self.center.y, [SVPSizeUtils svp_width] - 100, 20);
    self.svp_messageTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.svp_messageTitleLabel.font = [UIFont systemFontOfSize:17.0];
    self.svp_messageTitleLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.svp_messageTitleLabel];
    
    self.svp_timeLabel = [[UILabel alloc]init];
    self.svp_timeLabel.frame = CGRectMake(60, self.frame.size.height+5, [SVPSizeUtils svp_width] - 70, 15);
    self.svp_timeLabel.textAlignment = NSTextAlignmentLeft;
    self.svp_timeLabel.font = [UIFont systemFontOfSize:15.0];
    self.svp_timeLabel.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:self.svp_timeLabel];
    
    
}
@end
