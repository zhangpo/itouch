//
//  BSAdditionsView.h
//  BookSystem-iPhone
//
//  Created by Stan Wu on 13-1-14.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPadding 10

@protocol ZCAdditionsViewDelegate

- (void)additionsSelected:(NSArray *)additions;

@end

@interface ZCAdditionsView : UIView<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>{
    UITableView *tvList;
    
    NSMutableArray *arySelectedAdditions,*aryResult,*aryCustomAddition,*arySearchMatched;
    id<ZCAdditionsViewDelegate> delegate;
    UISearchBar *searchBar;
}
@property (nonatomic,assign) id<ZCAdditionsViewDelegate> delegate;

+ (ZCAdditionsView *)additionsViewWithDelegate:(id<ZCAdditionsViewDelegate>)delegate_ additions:(NSArray *)additions;
- (void)show;
@end

