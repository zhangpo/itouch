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

@protocol OpenTableViewDelegate

- (void)openTableWithOptions:(NSDictionary *)info;

@end


@interface BSOpenTableView : BSRotateView<UITextFieldDelegate> {
    UIButton *btnConfirm,*btnCancel;
    UILabel *manLable,*womanLable;
    UITextField *tfman,*tfwoman;
    CVLocalizationSetting *langSetting;
    id<OpenTableViewDelegate> delegate;
}
@property (nonatomic,assign) id<OpenTableViewDelegate> delegate;

@end
