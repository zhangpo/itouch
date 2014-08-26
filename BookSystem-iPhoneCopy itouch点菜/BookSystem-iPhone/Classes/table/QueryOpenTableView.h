//
//  QueryOpenTableView.h
//  BookSystem-iPhone
//
//  Created by dcw on 13-12-26.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import "BSRotateView.h"
#import "CVLocalizationSetting.h"

@protocol QueryOpenTableViewDelegate

- (void)queryOpenTableWithOptions:(NSDictionary *)info;

@end

@interface QueryOpenTableView : BSRotateView {
    UIButton *btnConfirm,*btnCancel;
    UILabel *manLable,*womanLable,*tableLable;
    UITextField *tfman,*tfwoman,*tfTable;
    
    id<QueryOpenTableViewDelegate> delegate;
    CVLocalizationSetting *langSetting;
}
@property (nonatomic,assign) id<QueryOpenTableViewDelegate> delegate;

@end
