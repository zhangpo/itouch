//
//  BSCancelTableView.h
//  BookSystem
//
//  Created by Dream on 11-7-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSRotateView.h"

@protocol  ZCCancelTableViewDelegate

- (void)cancelTableWithOptions:(NSDictionary *)info;

@end

@interface ZCCancelTableView : BSRotateView<UITextFieldDelegate> {
    UIButton *btnConfirm,*btnCancel;
    
    UILabel *lblUser;
    
    UITextField *tfUser;
    
    id<ZCCancelTableViewDelegate> delegate;
}

@property (nonatomic,assign) id<ZCCancelTableViewDelegate> delegate;


@end
