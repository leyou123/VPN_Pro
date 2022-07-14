//
//  SVPPurchaseHistoryTableViewCell.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/29.
//

#import "SVPPurchaseHistoryTableViewCell.h"
#import "SVPSizeUtils.h"

@implementation SVPPurchaseHistoryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self initTableViewCellUI];
    }
    return self;
}

- (void)initTableViewCellUI{
    NSArray *titleArr = @[NSLocalizedString(@"VIPVariety", nil),NSLocalizedString(@"PurchaseDate", nil),NSLocalizedString(@"VIPDuration", nil),NSLocalizedString(@"VIPPrice", nil)];
    for (int i = 0; i < 4; i++) {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, ([SVPSizeUtils svp_width] / 12 + 5) + [SVPSizeUtils svp_width] / 12 *i, 120, 20)];
        titleLabel.text = [titleArr objectAtIndex:i];
        titleLabel.textColor = [UIColor colorWithRed:0.38 green:0.38 blue:0.38 alpha:1.00];
        titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [self addSubview:titleLabel];
        
        if (i == 0) {
            self.svp_product_name = [[UILabel alloc]init];
            self.svp_product_name.frame = CGRectMake([SVPSizeUtils svp_width] - 150, ([SVPSizeUtils svp_width] / 12 + 5), 120,20);
            self.svp_product_name.textColor = [UIColor colorWithRed:0.38 green:0.38 blue:0.38 alpha:1.00];
            self.svp_product_name.font = [UIFont systemFontOfSize:15.0f];
            self.svp_product_name.backgroundColor = [UIColor clearColor];
            self.svp_product_name.textAlignment = NSTextAlignmentRight;
            [self.contentView addSubview:self.svp_product_name];
        }
        if (i == 1) {
            self.svp_purchase_date = [[UILabel alloc]init];
            self.svp_purchase_date.frame = CGRectMake([SVPSizeUtils svp_width] - 130, ([SVPSizeUtils svp_width] / 12 + 5) + [SVPSizeUtils svp_width] / 12, 100,20);
            self.svp_purchase_date.textColor = [UIColor colorWithRed:0.38 green:0.38 blue:0.38 alpha:1.00];
            self.svp_purchase_date.font = [UIFont systemFontOfSize:15.0f];
            self.svp_purchase_date.backgroundColor = [UIColor clearColor];
            self.svp_purchase_date.textAlignment = NSTextAlignmentRight;
            [self.contentView addSubview:self.svp_purchase_date];
        }
        if (i == 2) {
            self.svp_product_day = [[UILabel alloc]init];
            self.svp_product_day.frame = CGRectMake([SVPSizeUtils svp_width] - 130,([SVPSizeUtils svp_width] / 12 + 5) + [SVPSizeUtils svp_width] / 12*2, 100, 20);
            self.svp_product_day.textColor = [UIColor colorWithRed:0.38 green:0.38 blue:0.38 alpha:1.00];
            self.svp_product_day.font = [UIFont systemFontOfSize:15.0f];
            self.svp_product_day.backgroundColor = [UIColor clearColor];
            self.svp_product_day.textAlignment = NSTextAlignmentRight;
            [self.contentView addSubview:self.svp_product_day];
        }
        if (i == 3) {
            self.svp_amount = [[UILabel alloc]init];
            self.svp_amount.frame = CGRectMake([SVPSizeUtils svp_width] - 130,([SVPSizeUtils svp_width] / 12 + 5) + [SVPSizeUtils svp_width] / 12*3, 100, 20);
            self.svp_amount.textColor = [UIColor colorWithRed:0.38 green:0.38 blue:0.38 alpha:1.00];
            self.svp_amount.font = [UIFont systemFontOfSize:15.0f];
            self.svp_amount.backgroundColor = [UIColor clearColor];
            self.svp_amount.textAlignment = NSTextAlignmentRight;
            [self.contentView addSubview:self.svp_amount];
        }
    }
    
    
    
}

@end
