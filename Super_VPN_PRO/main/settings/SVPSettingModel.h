//
//  SVPSettingModel.h
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SVPSettingModel : NSObject
@property (copy, readwrite, nonatomic)NSString *svp_isVipString;
@property (copy, readwrite, nonatomic)NSString *svp_productNameString;
@property (copy, readwrite, nonatomic)NSString *svp_expirtTimeString;

@end

NS_ASSUME_NONNULL_END
