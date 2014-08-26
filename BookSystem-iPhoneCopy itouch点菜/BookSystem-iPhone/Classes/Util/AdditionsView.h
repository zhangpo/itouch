//
//  AdditionsView.h
//  BookSystem-iPhone
//
//  Created by dcw on 14-2-20.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPadding 10

@protocol AdditionsViewDelegate

- (void)Selected:(NSArray *)additions;

@end

@interface AdditionsView : UIView<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>{
    UITableView *tvList;
    
    NSMutableArray *arySelectedAdditions,*aryResult;
    id<AdditionsViewDelegate> delegate;
}
@property (nonatomic,assign) id<AdditionsViewDelegate> delegate;

+ (AdditionsView *)additionsViewWithDelegate:(id<AdditionsViewDelegate>)delegate_ additions:(NSArray *)additions;
- (void)show;
@end
