//
//  TouchTableView.h
//  fanqieDian
//
//  Created by chenzhihui on 13-11-7.
//  Copyright (c) 2013年 chenzhihui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TouchTableViewDelegate.h"
@protocol TouchTableViewDelegate;
@interface TouchTableView : UITableView
@property (nonatomic,assign) id<TouchTableViewDelegate> touchDelegate;
@end
