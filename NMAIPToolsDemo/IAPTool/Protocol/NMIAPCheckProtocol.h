//
//  NMIAPCheckProtocol.h
//  LemonLive
//
//  Created by 吴鸿 on 2020/3/17.
//  Copyright © 2020 liuxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NMIAPLocalModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NMIAPCheckProtocol <NSObject>

/// 网络验证订单
/// @param iapModel 商品模型参数
/// @param cb isNetSussess==false,会进行延时二次验证
- (void)updateReceiptWithIAPModel:(NMIAPLocalModel*)iapModel
                           cb:(void (^) (bool isPHPSucess,bool isNetSussess))cb;

@end

NS_ASSUME_NONNULL_END
