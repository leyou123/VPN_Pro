//
//  GBPingTool.h
//  Ping
//
//  Created by one on 2019/12/18.
//  Copyright © 2019 one. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GBPing.h"
NS_ASSUME_NONNULL_BEGIN

typedef void(^ResultCallback)(BOOL success,GBPingSummary * summary);


@interface GBPingTool : NSObject
+ (instancetype)shared;
- (void)ping:(NSString *)host result: (ResultCallback)callBack;
@end

NS_ASSUME_NONNULL_END
