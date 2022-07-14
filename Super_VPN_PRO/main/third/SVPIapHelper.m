//
//  SVPIapHelper.m
//  Super_VPN_PRO
//
//  Created by MacOSDaye on 2021/9/30.
//

#import "SVPIapHelper.h"
#import <NSString+Base64.h>

@implementation SVPIapHelper
+ (NSString *)svp_base64receipt {
    NSData *svp_receiptData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
    return [NSString base64StringFromData:svp_receiptData length:[svp_receiptData length]];
}


+ (void)svp_checkReceiptWithShareSecret:(NSString *)shareSecret sandBoxMode:(BOOL)isSandBox onCompletion:(void(^)(NSDictionary *result))completion {
    IAPHelper *svp_iapHelper = [[IAPHelper alloc] init];
    svp_iapHelper.production = !isSandBox;
    [svp_iapHelper checkReceipt:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] AndSharedSecret:shareSecret onCompletion:^(NSString *response, NSError *error) {
        NSDictionary *dictionary = [SVPIapHelper decodeObject:response];
        if ([dictionary[@"status"] intValue] == 21007 || [dictionary[@"status"] intValue] == 21008) {
            [SVPIapHelper svp_checkReceiptWithShareSecret:shareSecret sandBoxMode:!isSandBox onCompletion:completion];
        }else {
            if (completion) {
                completion(dictionary);
            }
        }
    }];
}

+ (void)svp_purchase:(NSString *)productID onCompletion:(void(^)(BOOL success, SKPaymentTransaction *transcation))completion {
    NSSet* dataSet = [[NSSet alloc] initWithObjects:productID, nil];
    IAPHelper *svp_iapHelper = [[IAPHelper alloc] initWithProductIdentifiers:dataSet];
    NSString *__block idKey;
    [svp_iapHelper requestProductsWithCompletion:^(SKProductsRequest *request, SKProductsResponse *response) {
        SKProduct *product = response.products.firstObject;
        if (product) {
            [svp_iapHelper buyProduct:product onCompletion:^(SKPaymentTransaction *transcation) {
                if (![transcation.payment.productIdentifier isEqualToString:productID]) {
                    NSLog(@"~~~~~productIdentifier:%@,productID:%@",transcation.payment.productIdentifier,productID);
                    return;
                }
                if (idKey) {
                    NSLog(@"~~~~~idKey:%@",idKey);
                    return;
                }
                NSString *key = [NSString stringWithFormat:@"%p",transcation];
                switch (transcation.transactionState) {
                    case SKPaymentTransactionStateFailed:
                        if (completion) {
                            idKey = key;
                            completion(NO, transcation);
                        }
                        break;
                    case SKPaymentTransactionStateRestored:
                        if (completion) {
                            idKey = key;
                            completion(YES, transcation);
                        }
                        break;
                    case SKPaymentTransactionStatePurchased:
                        if (completion) {
                            idKey = key;
                            completion(YES, transcation);
                        }
                        break;
                    default:
                        break;
                }
            }];
        }else {
            NSLog(@"商品获取失败");
            if (completion) {
                completion(NO, nil);
            }
        }
    }];
}

+ (void)svp_restorePurchase:(void(^)(SKPaymentQueue *payment, NSError *error))completion {
    [[[IAPHelper alloc] init] restoreProductsWithCompletion:^(SKPaymentQueue *payment, NSError *error) {
        if (completion) {
            completion(payment, error);
        }
    }];
}


+ (NSDictionary *)decodeObject:(NSString *)svp_String {
    NSError *error;
    NSDictionary *svp_dictionary = [NSJSONSerialization JSONObjectWithData:[svp_String dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (error) {
        NSLog(@"解析失败");
        return nil;
    }else {
        return svp_dictionary;
    }
}

@end
