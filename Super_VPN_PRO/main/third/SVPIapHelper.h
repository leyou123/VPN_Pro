//
//  SVPIapHelper.h
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/30.
//

#import <Foundation/Foundation.h>
#import <IAPHelper/IAPHelper.h>
NS_ASSUME_NONNULL_BEGIN

@interface SVPIapHelper : NSObject
+ (NSString *)svp_base64receipt;
+ (void)svp_checkReceiptWithShareSecret:(NSString *)shareSecret sandBoxMode:(BOOL)isSandBox onCompletion:(void(^)(NSDictionary *result))completion;
+ (void)svp_purchase:(NSString *)productID onCompletion:(void(^)(BOOL success, SKPaymentTransaction *transcation))completion;
+ (void)svp_restorePurchase:(void(^)(SKPaymentQueue *payment, NSError *error))completion;
@end

NS_ASSUME_NONNULL_END
