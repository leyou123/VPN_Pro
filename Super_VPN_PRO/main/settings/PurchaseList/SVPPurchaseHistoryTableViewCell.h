//
//  SVPPurchaseHistoryTableViewCell.h
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SVPPurchaseHistoryTableViewCell : UITableViewCell
@property (nonatomic,strong)UILabel *svp_product_name;
@property (nonatomic,strong)UILabel *svp_purchase_date;
@property (nonatomic,strong)UILabel *svp_product_day;
@property (nonatomic,strong)UILabel *svp_amount;
@end

NS_ASSUME_NONNULL_END
