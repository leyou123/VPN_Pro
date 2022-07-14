//
//  SVPLinesTableViewCell.h
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SVPLinesTableViewCell : UITableViewCell
@property (nonatomic, strong)UIImageView *svp_linesCountryImageView;
@property (nonatomic, strong)UILabel *svp_lineNameLabel;
@property (nonatomic, strong)UILabel *svp_lineDelayLabel;
@property (nonatomic, strong)UILabel *svp_lineRecommendLabel;
@property (nonatomic, strong)UIView *svp_delayView;
@end

NS_ASSUME_NONNULL_END
