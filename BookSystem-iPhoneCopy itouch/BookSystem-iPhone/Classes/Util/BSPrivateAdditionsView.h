//
//  BSAdditionsView.h
//  BookSystem-iPhone
//
//  Created by Stan Wu on 13-1-14.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPadding 10

@protocol BSAdditionsViewDelegate

- (void)additionsSelected:(NSArray *)additions;

@end

@interface BSAdditionsView : UIView<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>{
    UITableView *tvList;
    
    NSMutableArray *arySelectedAdditions,*aryResult;
    id<BSAdditionsViewDelegate> delegate;
}
@property (nonatomic,assign) id<BSAdditionsViewDelegate> delegate;

+ (BSAdditionsView *)additionsViewWithDelegate:(id<BSAdditionsViewDelegate>)delegate_ additions:(NSArray *)additions;
- (void)show;
@end
