//
//  NMIAPLocalModel.h
//  LemonLive
//
//  Created by 吴鸿 on 2020/3/17.
//  Copyright © 2020 liuxy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NMIAPLocalModel : NSObject<NSCoding>

/// 商品的凭证
@property(nonatomic,copy)NSString *receipt;
/// 商品的类别
@property(nonatomic,assign)NSUInteger  productType;
/// 重复请求网络验证的次数
@property(nonatomic,assign)NSUInteger  retryTime;
/// 商品id
@property(nonatomic,strong)NSString *productID;

+ (void)archivedWith:(NMIAPLocalModel*)model;
+ (instancetype _Nullable)unarchiveFile;
+ (BOOL)removeArchiver;
- (void)initDefault;

@end

NS_ASSUME_NONNULL_END
