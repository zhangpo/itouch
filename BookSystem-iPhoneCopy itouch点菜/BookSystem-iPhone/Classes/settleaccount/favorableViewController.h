//
//  favorableViewController.h
//  BookSystem-iPhone
//
//  Created by dcw on 14-3-13.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol favorableDelegate <NSObject>

-(void)counp:(NSDictionary *)dic;

@end

@interface favorableViewController : UIViewController<UIScrollViewDelegate>{
    NSArray  *aryFeiLei,*aryCounp;
    NSMutableArray *aryFeiLeiItem;
    UIScrollView *scvTables;
    
    id<favorableDelegate> delegate;
    int fenleiLine;
}

@property(nonatomic,retain) NSDictionary *dicInfo;
@property(nonatomic,assign) id<favorableDelegate> delegate;

@end
