//
//  sharedData.m
//  BookSystem-iPhone
//
//  Created by dcw on 14-3-12.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import "sharedData.h"

@implementation sharedData
@synthesize yingFuMoney,yingShouMoney,moLingMoney,orderMoney,zhaoLingMoney;

static sharedData *sharedInstance = nil;
+ (sharedData *)sharedInstance {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[sharedData alloc] init];
        }
    }
    return sharedInstance;
}
@end
