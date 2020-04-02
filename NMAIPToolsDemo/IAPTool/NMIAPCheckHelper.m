//
//  NMIAPCheckHelper.m
//  LemonLive
//
//  Created by 吴鸿 on 2020/3/16.
//  Copyright © 2020 liuxy. All rights reserved.
//

#import "NMIAPCheckHelper.h"
#import "NMIAPCheckProtocol.h"

@implementation NMIAPCheckHelper

+ (instancetype)shared {
    static NMIAPCheckHelper *checkHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        checkHelper = [[NMIAPCheckHelper alloc] init];
    });
    return checkHelper;
}

/// 网络验证订单
/// @param iapModel 商品模型参数
-(void)updateReceiptWithIAPModel:(NMIAPLocalModel *)iapModel cb:(void (^)(bool, bool))cb{
    
//        //防止漏单，需要重复请求
//        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary: @{
//            @"token":iapModel.receipt,
//        }];
//        
//        [NMNetManage postUrl:appleRecharge parameters:params sucessBlock:^(NMNetModel * _Nonnull resultDict) {
//            if (resultDict.code == 0) {
//                cb(true,true);
//            }else{
//                cb(false,true);
//            }
//        } failureBlock:^(BOOL isFailure) {
//            cb(false,false);
//        }];
    
}




@end
