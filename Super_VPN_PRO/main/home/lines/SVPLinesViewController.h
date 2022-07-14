//
//  SVPLinesViewController.h
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class SVPLinesViewController;
@protocol SVPLinesViewControllerDelegate <NSObject>
- (void)svp_setupLinesSelectedAutoConnect:(SVPLinesViewController *)svp_linesVC;
@end

@interface SVPLinesViewController : UIViewController
@property (nonatomic, weak) id<SVPLinesViewControllerDelegate> delegate;
@property (nonatomic,strong)NSString *svp_allow_trial_time;
@property (nonatomic,strong)NSString *svp_allow_trial_traffic;
@property (nonatomic,strong)NSString *svp_is_trial;
@property (nonatomic,strong)NSString *svp_lineIsVIP;
@end

NS_ASSUME_NONNULL_END
