//
//  NMIAPHelper.m
//  LemonLive
//
//  Created by 吴鸿 on 2020/3/16.
//  Copyright © 2020 liuxy. All rights reserved.
//

#import "NMIAPHelper.h"
#import "NMIAPLocalModel.h"

@interface NMIAPHelper()<SKPaymentTransactionObserver> {
    BOOL _isInited;
    BOOL _isBusy;
    IAPCompletionHandle _handle;
    //恢复购买相关
    NSInteger _pendingRestoredTransactionsCount;
    BOOL _restoredCompletedTransactionsFinished;
    NSMutableArray * _restoredTransactions;
    void (^_restoreTransactionsFailureBlock)(NSError* error);
    void (^_restoreTransactionsSuccessBlock)(NSArray* transactions);
}

@property(nonatomic,assign)NSUInteger  retryTime;
@property(nonatomic,strong)NMIAPRequestHelper * requestHelper;
@property (nonatomic, weak) id <NMIAPCheckProtocol> checkDelegate;
@property (nonatomic, weak, nullable) id <NMMonitorProtocol> monitorDelegate;
/// 当前请求的产品数据
@property(nonatomic,strong,nullable)NMIAPLocalModel *currentIAPLocalModel;

@end

@implementation NMIAPHelper

+ (instancetype)shared {
    static NMIAPHelper *IAPManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        IAPManager = [[NMIAPHelper alloc] init];
        IAPManager.requestHelper = [[NMIAPRequestHelper alloc] init];
    });
    return IAPManager;
}

/// 初始化IAP
/// @param checker 后端支付校验者
/// @param monitor 支付过程监听者
-(void)initializeWithCheckDelegate:(id<NMIAPCheckProtocol>)checker monitor:(id<NMMonitorProtocol> _Nullable)monitor{
    
    if (!_isInited) {
        _restoredTransactions = [NSMutableArray array];
        self.checkDelegate = checker;
        self.monitorDelegate = monitor;
        self.currentIAPLocalModel = [NMIAPLocalModel unarchiveFile];
        if (!self.currentIAPLocalModel) {
            self.currentIAPLocalModel = [[NMIAPLocalModel alloc] init];
            [self.currentIAPLocalModel initDefault];
        }
        //苹果支付成功后，服务器后端没有验证成功，进行验证
        if (self.currentIAPLocalModel.receipt && self.currentIAPLocalModel.receipt.length > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self retryingCheck];
            });
        }
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        _isInited = true;
    }

}

/// 进行内购请求
/// @param productId 商品ID
/// @param type 内购商品类型
/// @param handle 支付结果回调
- (void)startIAPWithProductWithProductId:(NSString *)productId type:(NMIAPType)type completeHandle: (IAPCompletionHandle)handle {
    if (_isBusy) {
        if(handle){
            handle(IAPResultPaying);
        }
        return ;
    }
    _handle = handle;
    if ([SKPaymentQueue canMakePayments]) {
        /// 开始进行内购
        if (self.monitorDelegate) [self.monitorDelegate startIAPWithProductId:productId];
        //本地化内购参数
        NMIAPLocalModel *iapLocalModel = [[NMIAPLocalModel alloc] init];
        iapLocalModel.productID = productId;
        iapLocalModel.productType = type;
        iapLocalModel.retryTime = 0;
        self.currentIAPLocalModel = iapLocalModel;
        [NMIAPLocalModel archivedWith:iapLocalModel];
        
        NSSet *productIds = [NSSet setWithObject:productId];
        //获取商品信息
        [self.requestHelper requestProductsWithProductIdentifiers:productIds
                                                       Completion:^(SKProductsRequest * _Nullable request,
                                                                                          SKProductsResponse * _Nullable response,
                                                                                          NSArray * _Nullable modelArr) {
            if (response && response.products.count > 0) {
                // 请求体
                SKPayment *payMent = [SKPayment paymentWithProduct:response.products.firstObject];
                // 发起内购
                [[SKPaymentQueue defaultQueue] addPayment:payMent];
                
            }else if(!response){
                //appstore连接失败
                [self handleActionWithType:IAPResultiTunesError data:nil];
            }else{
                //商品id有问题
                [self handleActionWithType:IAPResultIDError data:nil];
            }
        }];
        
    }else{
        // 不允许内购
        [self handleActionWithType:IAPResultNotArrow data:nil];
    }
    
}

/// 进行恢复购买
/// @param successBlock 成功回调
/// @param failureBlock 失败回调
- (void)restoreTransactionsOnSuccess:(void (^)(NSArray *transactions))successBlock
                             failure:(void (^)(NSError *error))failureBlock
{
    _restoredCompletedTransactionsFinished = NO;
    _pendingRestoredTransactionsCount = 0;
    _restoredTransactions = [NSMutableArray array];
    _restoreTransactionsSuccessBlock = successBlock;
    _restoreTransactionsFailureBlock = failureBlock;
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)notifyRestoreTransactionFinishedIfApplicableAfterTransaction:(SKPaymentTransaction*)transaction
{
    if (transaction != nil)
    {
        [_restoredTransactions addObject:transaction];
        _pendingRestoredTransactionsCount--;
    }
    if (_restoredCompletedTransactionsFinished && _pendingRestoredTransactionsCount == 0)
    { // Wait until all restored transations have been verified
        NSArray *restoredTransactions = [_restoredTransactions copy];
        if (_restoreTransactionsSuccessBlock != nil)
        {
            _restoreTransactionsSuccessBlock(restoredTransactions);
            _restoreTransactionsSuccessBlock = nil;
        }
    }
}

#pragma mark --  SKPaymentTransactionObserver

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    
    if ([SKPaymentQueue defaultQueue]) {
        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    }
    
    /// 苹果内购成功
    if (self.monitorDelegate) [self.monitorDelegate IAPResultWithSussess:self.currentIAPLocalModel.productID];
    
    NSURL *recepitURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receipt = [NSData dataWithContentsOfURL:recepitURL];
    if (receipt) {
        [self updateReceiptWithData:receipt];
    }else{
        [self handleActionWithType:IAPResultVerFailed data:nil];
    }
    
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    
    _pendingRestoredTransactionsCount++;
    [self notifyRestoreTransactionFinishedIfApplicableAfterTransaction:transaction];
    
    if ([SKPaymentQueue defaultQueue]) {
        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    }
    
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    if (transaction.error.code != SKErrorPaymentCancelled) {
        if (self.monitorDelegate) [self.monitorDelegate IAPResultWithFail:self.currentIAPLocalModel.productID];
        [self handleActionWithType:IAPResultFailed data:nil];
    }else{
        if (self.monitorDelegate) [self.monitorDelegate IAPResultWithCancle:self.currentIAPLocalModel.productID];
        [self handleActionWithType:IAPResultCancle data:nil];
    }

    if ([SKPaymentQueue defaultQueue]) {
        [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    }
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    
    for (SKPaymentTransaction *trans in transactions) {
        
        switch (trans.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                if (trans.originalTransaction) {
                    // 如果是自动续费的订单originalTransaction会有内容
                    self.currentIAPLocalModel.productType = IAPSubscribe;
                    if (self.currentIAPLocalModel.productID.length == 0) {
                        self.currentIAPLocalModel.productID = trans.payment.productIdentifier;
                    }
                }
                [self completeTransaction:trans];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:trans];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:trans];
            default:
                break;
        }
        
    }
}

-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    NSLog(@"restored transactions failed with error %@", error.debugDescription);
    if (_restoreTransactionsFailureBlock != nil)
    {
        _restoreTransactionsFailureBlock(error);
        _restoreTransactionsFailureBlock = nil;
    }
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
    
    _restoredCompletedTransactionsFinished = YES;
    [self notifyRestoreTransactionFinishedIfApplicableAfterTransaction:nil];
    
}

- (void)handleActionWithType:(IAPResultType)type data:(NSData *)data{
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_isBusy = NO;
        switch (type) {
            case IAPResultSuccess:
                NSLog(@"购买成功");
                break;
            case IAPResultFailed:
                NSLog(@"购买失败");
                break;
            case IAPResultCancle:
                NSLog(@"用户取消购买");
                break;
            case IAPResultVerFailed:
                NSLog(@"订单校验失败");
                break;
            case IAPResultVerSuccess:
                NSLog(@"订单校验成功");
                break;
            case IAPResultNotArrow:
                NSLog(@"不允许程序内付费");
                break;
            case PHPResultVerFailed:
                NSLog(@"服务端返回失败");
            default:
                break;
        }
        //本次购买结束，清楚本地数据
        [NMIAPLocalModel removeArchiver];
        
        if(self->_handle){
            self->_handle(type);
        }
    });
}

/// 服务端校验
/// @param receiptData 二进制凭证
- (void)updateReceiptWithData:(NSData *)receiptData{
    
    if (!self.checkDelegate) {
        NSAssert(false, @"需要设置NMIAPCheckProtocol代理", nil);
    }
    
    self.retryTime = 0;
    //如果 续期订阅 存在的现象，只有凭证，其他东西都没有
    self.currentIAPLocalModel.receipt = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    [NMIAPLocalModel archivedWith:self.currentIAPLocalModel];
    [self retryingCheck];
    
}

-(void)retryingCheck{
    __weak typeof(self) weakSelf = self;
    [self.checkDelegate updateReceiptWithIAPModel:self.currentIAPLocalModel
                                           cb:^(bool isPHPSucess, bool isNetSussess) {
        
        //网络出错->进行延时校验
        if (!isNetSussess) {
            weakSelf.currentIAPLocalModel.retryTime ++;
            [NMIAPLocalModel archivedWith:weakSelf.currentIAPLocalModel];
            NSUInteger updateCount = weakSelf.currentIAPLocalModel.retryTime;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(updateCount < 10 ? 1 :updateCount * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (updateCount == 50) {
                    [NMIAPLocalModel removeArchiver];
                    return ;
                }
                [weakSelf retryingCheck];
            });
            return;
        }
        //服务端校验成功
        if (isPHPSucess) {
            if (weakSelf.monitorDelegate) [weakSelf.monitorDelegate PHPResultWithSussess:self.currentIAPLocalModel.productID];
            [weakSelf handleActionWithType:IAPResultSuccess data:nil];
            return;
        }
        //服务端校验失败
        if (weakSelf.monitorDelegate) [weakSelf.monitorDelegate PHPResultWithFail:self.currentIAPLocalModel.productID];
        [weakSelf handleActionWithType:PHPResultVerFailed data:nil];
        
    }];
}

@end
