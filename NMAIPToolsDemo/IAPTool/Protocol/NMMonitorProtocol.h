//
//  NMMonitorProtocol.h
//  LemonLive
//
//  Created by 吴鸿 on 2020/3/16.
//  Copyright © 2020 liuxy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NMMonitorProtocol <NSObject>

/// 开始进行内购
/// @param productId 产品id
-(void)startIAPWithProductId:(NSString *)productId;

/// 苹果内购成功
/// @param productId productId 产品id
-(void)IAPResultWithSussess:(NSString *)productId;

/// 苹果购买失败
/// @param productId productId 产品id
-(void)IAPResultWithFail:(NSString *)productId;

/// 苹果购买取消
/// @param productId productId 产品id
-(void)IAPResultWithCancle:(NSString *)productId;

/// 服务器校验成功
/// @param productId productId 产品id
-(void)PHPResultWithSussess:(NSString *)productId;

/// 服务器校验失败
/// @param productId productId 产品id
-(void)PHPResultWithFail:(NSString *)productId;

///// 恢复购买失败
//-(void)IAPResultRestoreFail;
//
///// 恢复购买成功
//-(void)IAPResultRestoreSuccess;

@end

NS_ASSUME_NONNULL_END
