//
//  sharedData.h
//  BookSystem-iPhone
//
//  Created by dcw on 14-3-12.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface sharedData : NSObject

+ (sharedData *)sharedInstance;

@property(nonatomic,copy) NSString *yingShouMoney;
@property(nonatomic,copy) NSString *yingFuMoney;
@property(nonatomic,copy) NSString *moLingMoney;
@property(nonatomic,copy) NSString *orderMoney;
@property(nonatomic,copy) NSString *zhaoLingMoney;


@end
