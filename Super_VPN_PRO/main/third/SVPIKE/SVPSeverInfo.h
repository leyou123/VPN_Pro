//
//  SVPSeverInfo.h
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SVPSeverInfo : NSObject

@property (nonatomic, strong) NSString *svp_serverAddress;
@property (nonatomic, strong) NSString *svp_remoteID;
@property (nonatomic, strong) NSString *svp_username;
@property (nonatomic, strong) NSString *svp_password;
@property (nonatomic, strong) NSString *svp_sharedSecret;
@property (nonatomic, strong) NSString *svp_preferenceTitle;

+ (instancetype)setupSVPInfoWithData:(id)svp_data;

@end

NS_ASSUME_NONNULL_END
