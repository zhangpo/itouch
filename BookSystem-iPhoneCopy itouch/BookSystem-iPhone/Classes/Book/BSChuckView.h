//
//  BSChunkView.h
//  BookSystem
//
//  Created by Dream on 11-5-24.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSRotateView.h"
#import "CVLocalizationSetting.h"

@protocol  ZCChuckViewDelegate

- (void)chuckOrderWithOptions:(NSDictionary *)info;

@end

@interface ZCChuckView : BSRotateView <UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate>{
    UIButton *btnChunk,*btnCancel;
    UILabel *lblAcct,*lblPwd,*lblCount,*lblReason;
    UITextField *tfAcct,*tfPwd,*tfCount;
    UIPickerView *pickerReason;
    
    NSMutableArray *aryReasons;
    
    id<ZCChuckViewDelegate> delegate;
    int dSelected;
    CVLocalizationSetting *langSetting;
}
@property (nonatomic,retain) NSMutableArray *aryReasons;
@property (nonatomic,assign) id<ZCChuckViewDelegate> delegate;


@end
