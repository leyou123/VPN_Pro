//
//  SVPConnector.h
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/13.
//

#import <Foundation/Foundation.h>
#import "SVPSeverInfo.h"
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, SVPServerStatus) {
    SVPServerStatusInvalid,
    SVPServerStatusDisconnected,
    SVPServerStatusConnecting,
    SVPServerStatusConnected,
    SVPServerStatusDisconnecting,
};

typedef NS_ENUM(NSUInteger, SVPServerConnectorError) {
    SVPServerConnectorErrorNone,
    SVPServerConnectorErrorLoadPrefrence,
    SVPServerConnectorErrorSavePrefrence,
    SVPServerConnectorErrorRemovePrefrence,
    SVPServerConnectorErrorStartVPNConnect
};

@protocol SVPServerConnectorDelegate <NSObject>

- (void)svpServerConnectionDidRecieveError:(SVPServerConnectorError)error;
- (void)svpServerStatusDidChange:(SVPServerStatus)status;

@end

@interface SVPConnector : NSObject
@property (nonatomic, weak) id<SVPServerConnectorDelegate> delegate;

+ (instancetype)svp_ServerConnector;

- (void)checkSVPServerPreferenceSuccess:(void (^)(BOOL isInstalled))successBlock;
- (void)createSVPServerPreferenceWithData:(id)data success:(void (^)(void))successBlock;
- (void)removeSVPServerPreferenceSuccess:(void (^)(void))successBlock;
- (void)modifySVPServerPreferenceWithData:(id)data success:(void (^)(void))successBlock;

- (void)startSVPServerConnectSuccess:(void (^)(void))successBlock;
- (void)stopSVPServerConnectSuccess:(void (^)(void))successBlock;

- (SVPSeverInfo *)getCurrentSVPServerInfo;
- (SVPServerStatus)getCurrentSVPServerStatus;
@end

NS_ASSUME_NONNULL_END
