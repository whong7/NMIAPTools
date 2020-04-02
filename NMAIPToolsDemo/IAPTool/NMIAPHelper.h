//
//  NMIAPHelper.h
//  LemonLive
//
//  Created by 吴鸿 on 2020/3/16.
//  Copyright © 2020 liuxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NMIAPRequestHelper.h"
#import "NMIAPCheckProtocol.h"
#import "NMMonitorProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    IAPExpend = 1,       // 消耗型
    IAPSubscribe = 2,     // 订阅型
} NMIAPType;

typedef NS_ENUM(NSUInteger,IAPResultType) {
    IAPResultSuccess = 0,       // 购买成功
    IAPResultFailed = 1,        // 购买失败
    IAPResultCancle = 2,        // 取消购买
    IAPResultVerFailed = 3,     // 订单校验失败
    IAPResultVerSuccess = 4,    // 订单校验成功
    IAPResultNotArrow = 5,      // 不允许内购
    IAPResultIDError = 6,       // 项目ID错误
    IAPResultiTunesError = 7,   // 无法连接到 iTunes Store
    PHPResultVerFailed = 8,     // 后端返回错误
    IAPResultPaying = 9,        // 正在购买中
};

typedef void(^IAPCompletionHandle)(IAPResultType type);

@interface NMIAPHelper : NSObject

/// 单例操作
+ (instancetype)shared;

/// 初始化购买
/// @param checker 校验者
/// @param monitor 观察者
-(void)initializeWithCheckDelegate:(id<NMIAPCheckProtocol>)checker
                           monitor:(id<NMMonitorProtocol> _Nullable)monitor;
/// 进行购买
/// @param productId 内购id
/// @param type 内购类别
/// @param handle 回调
- (void)startIAPWithProductWithProductId:(NSString *)productId
                                    type:(NMIAPType)type
                          completeHandle:(IAPCompletionHandle)handle;

/// 进行恢复购买
/// @param successBlock 成功回调->所有订单
/// @param failureBlock 失败回调
- (void)restoreTransactionsOnSuccess:(void (^)(NSArray *transactions))successBlock
                             failure:(void (^)(NSError *error))failureBlock;

@end

NS_ASSUME_NONNULL_END
