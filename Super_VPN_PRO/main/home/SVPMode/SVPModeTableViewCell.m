//
//  SVPModeTableViewCell.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/18.
//

#import "SVPModeTableViewCell.h"
#import "SVPSizeUtils.h"

@implementation SVPModeTableViewCell

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
        [self setupModeCellUI];
    }
    return self;
}

- (void)setupModeCellUI {
    self.svp_modeSelectedImageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 16, 41/2, 41/2)];
    [self.contentView addSubview:self.svp_modeSelectedImageView];
    
    self.svp_modeTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 15, [SVPSizeUtils svp_width] / 2, 20)];
    self.svp_modeTitleLabel.textColor = [UIColor colorWithRed:24.0/255.0 green:189.0/255.0 blue:241.0/255.0 alpha:1.00];
    self.svp_modeTitleLabel.font = [UIFont fontWithName:@"Helvetica-Oblique" size:18.0];
    self.svp_modeTitleLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.self.svp_modeTitleLabel];
    
    NSArray *svp_protocalArray = @[NSLocalizedString(@"protocolA2", nil),NSLocalizedString(@"protocolA3", nil),NSLocalizedString(@"protocolA4", nil),NSLocalizedString(@"protocolA5", nil)];

    for (int i = 0; i < svp_protocalArray.count; i++) {
        UILabel *svp_subtitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20,45 + 25 *i, [SVPSizeUtils svp_width] / 2.3, 25)];
        svp_subtitleLabel.textColor = [UIColor colorWithRed:24.0/255.0 green:189.0/255.0 blue:241.0/255.0 alpha:1.00];
        svp_subtitleLabel.font = [UIFont fontWithName:@"Helvetica-Oblique" size:15.0];
        svp_subtitleLabel.text = [svp_protocalArray objectAtIndex:i];
        svp_subtitleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:svp_subtitleLabel];
      
    }
}
@end
