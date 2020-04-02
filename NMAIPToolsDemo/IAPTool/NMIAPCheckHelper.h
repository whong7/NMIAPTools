//
//  NMIAPCheckHelper.h
//  LemonLive
//
//  Created by 吴鸿 on 2020/3/16.
//  Copyright © 2020 liuxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NMIAPCheckProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface NMIAPCheckHelper : NSObject<NMIAPCheckProtocol>
+ (instancetype)shared;
@end

NS_ASSUME_NONNULL_END
