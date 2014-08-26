//
//  BSCancelTableView.h
//  BookSystem
//
//  Created by Dream on 11-7-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSRotateView.h"

@protocol  CancelTableViewDelegate

- (void)cancelTableWithOptions:(NSDictionary *)info;

@end

@interface BSCancelTableView : BSRotateView {
    UIButton *btnConfirm,*btnCancel;
    
    UILabel *lblUser;
    
    UITextField *tfUser;
    
    id<CancelTableViewDelegate> delegate;
}

@property (nonatomic,assign) id<CancelTableViewDelegate> delegate;


@end
