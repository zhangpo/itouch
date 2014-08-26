//
//  WaitViewController.h
//  BookSystem-iPhone
//
//  Created by dcw on 14-1-26.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CVLocalizationSetting.h"
#import "WaitTableView.h"
#import "ChangeWaitTableView.h"

@protocol WaitViewControllerDelegate 

-(void)refreshTable;

@end

@interface WaitViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,WaitTableViewDelegate,UIAlertViewDelegate,ChangeWaitTableViewDelegate>{
    UITableView *tvWait;
    CVLocalizationSetting *langSetting;
    NSMutableArray *aryWaitList;
    WaitTableView *waitView;
    NSArray *aryPhoneAndOrderId;
    NSString *phone;
    NSString *phone2;
    NSString *orderId;
    ChangeWaitTableView *changeView;
    id<WaitViewControllerDelegate> delegate;
}

@property(nonatomic,assign) id<WaitViewControllerDelegate> delegate;
@end
