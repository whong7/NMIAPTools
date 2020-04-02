//
//  ViewController.m
//  NMAIPToolsDemo
//
//  Created by 吴鸿 on 2020/4/1.
//  Copyright © 2020 whong7.com. All rights reserved.
//

#import "ViewController.h"
#import "NMIAPHelper.h"
#import "NMIAPCheckHelper.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [[NMIAPHelper shared] initializeWithCheckDelegate:[NMIAPCheckHelper shared] monitor:nil];
    
    
    // Do any additional setup after loading the view.
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    
    [[NMIAPHelper shared] startIAPWithProductWithProductId:@"1402"
                                                      type:IAPSubscribe
                                            completeHandle:^(IAPResultType type) {
        
        
        
        
        
        
        
        
    }];
    
    
    
    
    
}

@end
