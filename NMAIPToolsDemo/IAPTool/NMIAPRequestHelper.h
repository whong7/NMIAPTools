//
//  NMIAPRequestHelper.h
//  LemonLive
//
//  Created by 吴鸿 on 2020/3/16.
//  Copyright © 2020 liuxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

//模型转化协议
@protocol NMIAPRequestProtocol <NSObject>

@optional
//iap数据转换
- (NSArray *_Nullable)iAPRequestTransWithResponse:(SKProductsResponse *_Nullable)response;
@end


typedef void (^IAPProductsResponseBlock)(SKProductsRequest* _Nullable request , SKProductsResponse* _Nullable response , NSArray * _Nullable modelArr);

NS_ASSUME_NONNULL_BEGIN

@interface NMIAPRequestHelper : NSObject

@property (nonatomic,strong, nullable) SKProductsRequest *request;
@property (nonatomic, weak, nullable) id <NMIAPRequestProtocol> transDelegate;

/// 初始化
+ (instancetype)shared;

/// 获取商品信息
/// @param productIdentifiers 商品id集合
/// @param completion 回调
- (void)requestProductsWithProductIdentifiers:(NSSet *)productIdentifiers
                                   Completion:(IAPProductsResponseBlock)completion;

@end

NS_ASSUME_NONNULL_END
