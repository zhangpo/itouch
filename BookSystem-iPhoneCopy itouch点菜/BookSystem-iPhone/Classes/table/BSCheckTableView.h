//
//  BSCheckTableView.h
//  BookSystem
//
//  Created by Dream on 11-7-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSRotateView.h"

@protocol  CheckTableViewDelegate

- (void)checkTableWithOptions:(NSDictionary *)info;

@end

@interface BSCheckTableView : BSRotateView<UITableViewDelegate,UITableViewDataSource> {
    UIButton *btnCheck,*btnCancel;
    
    UILabel *lblAcct,*lblPwd,*lblFloor,*lblArea,*lblStatus;
    
    UITextField *tfAcct,*tfPwd;
    
    UIPickerView *vPicker;
    
    id<CheckTableViewDelegate> delegate;
    
    UITableView *tvArea,*tvFloor,*tvStatus;
    UIPopoverController *popArea,*popFloor,*popStatus;
    UIButton *btnArea,*btnFloor,*btnStatus;
    
    NSString *strArea,*strFloor,*strStatus;
}

@property (nonatomic,assign) id<CheckTableViewDelegate> delegate;
@property (nonatomic,copy) NSString *strArea,*strFloor,*strStatus;

@end
