//
//  BSOpenTableView.h
//  BookSystem
//
//  Created by Dream on 11-7-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSRotateView.h"
#import "CVLocalizationSetting.h"

@protocol ZCOpenTableViewDelegate

- (void)openTableWithOptions:(NSDictionary *)info;

@end


@interface ZCOpenTableView : BSRotateView<UITextFieldDelegate> {
    UIButton *btnConfirm,*btnCancel;
    UILabel *lblUser,*lblPeople,*lblWaiter;
    UITextField *tfUser,*tfPeople,*tfWaiter;
    
    id<ZCOpenTableViewDelegate> delegate;
    CVLocalizationSetting *langSetting;
}
@property (nonatomic,assign) id<ZCOpenTableViewDelegate> delegate;

@end
