//
//  NMIAPRequestHelper.m
//  LemonLive
//
//  Created by 吴鸿 on 2020/3/16.
//  Copyright © 2020 liuxy. All rights reserved.
//

#import "NMIAPRequestHelper.h"

@interface NMIAPRequestHelper()<SKProductsRequestDelegate>
@property (nonatomic,copy) IAPProductsResponseBlock requestProductsBlock;

@end

@implementation NMIAPRequestHelper

+ (instancetype)shared {
    static NMIAPRequestHelper *IAPManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        IAPManager = [[NMIAPRequestHelper alloc] init];
    });
    return IAPManager;
}

-(void)dealloc{
    _request.delegate = nil;
}

- (void)requestProductsWithProductIdentifiers:(NSSet *)productIdentifiers
                                   Completion:(IAPProductsResponseBlock)completion {
    
    self.request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    _request.delegate = self;
    self.requestProductsBlock = completion;
    [_request start];
    
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    self.request = nil;
    if(_requestProductsBlock) {
        if (self.transDelegate && [self.transDelegate respondsToSelector:@selector(iAPRequestTransWithResponse:)]) {
            NSArray *modelArray = [self.transDelegate iAPRequestTransWithResponse:response];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.requestProductsBlock(request,response,modelArray);
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.requestProductsBlock (request,response,nil);
            });
        }
    }
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    if(_requestProductsBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.requestProductsBlock (nil,nil,nil);
        });
    }
}

-(void)requestDidFinish:(SKRequest *)request{
    
}

#pragma mark localPrice
+(NSString *)localPrice:(SKProduct *)product{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];
    return formattedPrice;
}

@end
