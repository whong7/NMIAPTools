//
//  NMIAPLocalModel.m
//  LemonLive
//
//  Created by 吴鸿 on 2020/3/17.
//  Copyright © 2020 liuxy. All rights reserved.
//

#import "NMIAPLocalModel.h"

static NSString *docFileName = @"IAPLocal.archiver";

static NSString *receiptString = @"receipt";
static NSString *productTypeString = @"productType";
static NSString *retryTimeString = @"retryTime";
static NSString *productIDString = @"productID";

@implementation NMIAPLocalModel

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_receipt forKey:receiptString];
    [encoder encodeObject:@(_productType) forKey:productTypeString];
    [encoder encodeObject:@(_retryTime) forKey:retryTimeString];
    [encoder encodeObject:_productID forKey:productIDString];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self.receipt = [decoder decodeObjectForKey:receiptString];
    self.productID = [decoder decodeObjectForKey:productIDString];
    self.productType = [[decoder decodeObjectForKey:productTypeString] unsignedIntValue];
    self.retryTime = [[decoder decodeObjectForKey:retryTimeString] unsignedIntValue];
    
    return self;
}

+ (void )archivedWith:(NMIAPLocalModel*)model
{
    NSString *filePath = [self docFile:docFileName];
    [NSKeyedArchiver archiveRootObject:model toFile:filePath];
}

+ (instancetype _Nullable)unarchiveFile
{
    NSString *filePath = [self docFile:docFileName];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

+ (BOOL)removeArchiver
{
    NSString *filePath = [self docFile:docFileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL blHave = [fileManager fileExistsAtPath:filePath];
    if (blHave) {
        BOOL blDele= [fileManager removeItemAtPath:filePath error:nil];
        if (blDele) {
            return YES;
        }else {
            return NO;
        }
    }else{
        return NO;
    }
}

+ (NSString *)docFile:(NSString *)fileName
{
    NSString *docPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    NSString * filePath = [docPath stringByAppendingPathComponent:docFileName];
    return filePath;
}

-(void)initDefault{
    self.retryTime = 0;
    self.productType = 0;
    self.productID = @"";
    self.receipt = @"";
}


@end
