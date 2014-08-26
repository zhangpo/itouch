//
//  BSCheckTableView.h
//  BookSystem
//
//  Created by Dream on 11-7-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSRotateView.h"

@protocol  ZCCheckTableViewDelegate

- (void)checkTableWithOptions:(NSDictionary *)info;

@end

@interface ZCCheckTableView : BSRotateView<UITableViewDelegate,UITableViewDataSource> {
    UIButton *btnCheck,*btnCancel;
    
    UILabel *lblAcct,*lblPwd,*lblFloor,*lblArea,*lblStatus;
    
    UITextField *tfAcct,*tfPwd;
    
    UIPickerView *vPicker;
    
    id<ZCCheckTableViewDelegate> delegate;
    
    UITableView *tvArea,*tvFloor,*tvStatus;
    UIPopoverController *popArea,*popFloor,*popStatus;
    UIButton *btnArea,*btnFloor,*btnStatus;
    
    NSString *strArea,*strFloor,*strStatus;
}

@property (nonatomic,assign) id<ZCCheckTableViewDelegate> delegate;
@property (nonatomic,copy) NSString *strArea,*strFloor,*strStatus;

@end
