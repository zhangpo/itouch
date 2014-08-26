//
//  BSCombineTableView.h
//  BookSystem-iPhone
//
//  Created by dcw on 14-1-21.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import "BSRotateView.h"
#import "CVLocalizationSetting.h"

@protocol combineTableDelegate <NSObject>

-(void)combineTableWithOptions:(NSDictionary *)info;

@end
@interface BSCombineTableView : BSRotateView<UITextFieldDelegate>{
    UIButton *btnConfirm,*btnCancel;
    UILabel *lblOldTable,*lblNewTable;
    UITextField *tfOldTable,*tfNewTable;
    CVLocalizationSetting *langSetting;
    id<combineTableDelegate> delegate;
}
@property (nonatomic,assign) UITextField *tfOldTable,*tfNewTable;
@property (nonatomic,assign) id<combineTableDelegate> delegate;
@end
