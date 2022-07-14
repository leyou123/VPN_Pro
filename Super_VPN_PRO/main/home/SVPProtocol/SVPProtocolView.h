//
//  SVPProtocolView.h
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/18.
//

#import <UIKit/UIKit.h>
@class SVPProtocolView;
NS_ASSUME_NONNULL_BEGIN
@protocol SVProtocolViewDelegate <NSObject>
- (void)setupSVPLaunchProtocolViewClick:(SVPProtocolView *)svp_protocol;

@end

@interface SVPProtocolView : UIView
@property (nonatomic,weak)id<SVProtocolViewDelegate>svp_delegate;
@end

NS_ASSUME_NONNULL_END
