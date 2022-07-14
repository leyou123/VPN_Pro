//
//  SVPMainInfoModel.h
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SVPMainInfoModel : NSObject
@property (copy,readwrite, nonatomic)NSDictionary *svp_AdDataDic;
@property (copy,readwrite, nonatomic)NSDictionary *svp_Award_adDic;
@property (copy,readwrite, nonatomic)NSDictionary *svp_Speed_TestDic;

@property (copy,readwrite, nonatomic)NSString *svp_award_title;
@property (copy,readwrite, nonatomic)NSString *svp_service_mail;
@property (copy,readwrite, nonatomic)NSString *svp_is_blockString;
@property (copy,readwrite, nonatomic)NSString *svp_server_delay_type;
@property (copy,readwrite, nonatomic)NSString *svp_server_select_type;
@property (copy,readwrite, nonatomic)NSString *svp_service_url;
@property (copy,readwrite, nonatomic)NSString *svp_privacy_url;
@property (copy,readwrite, nonatomic)NSString *svp_purchase_verify_time;
@property (copy,readwrite, nonatomic)NSString *svp_traffic_update_time;

@property (copy,readwrite, nonatomic)NSString *svp_notice_switch;
@property (copy,readwrite, nonatomic)NSString *svp_update_switch;
@property (copy,readwrite, nonatomic)NSString *svp_update_url_switch;
@property (copy,readwrite, nonatomic)NSString *svp_update_url;
@property (copy,readwrite, nonatomic)NSString *svp_task_switch;

@end

NS_ASSUME_NONNULL_END
