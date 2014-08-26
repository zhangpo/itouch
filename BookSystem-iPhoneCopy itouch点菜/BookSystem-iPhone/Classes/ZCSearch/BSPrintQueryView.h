//
//  BSPrintQueryView.h
//  BookSystem
//
//  Created by Dream on 11-7-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSRotateView.h"

@protocol  PrintQueryViewDelegate

- (void)printQueryWithOptions:(NSDictionary *)info;

@end

@interface BSPrintQueryView : BSRotateView {
    UIButton *btnPrint,*btnCancel;
    
    UILabel *lblUser,*lblType;
    
    UITextField *tfUser;
    UISegmentedControl *segType;
    
    id<PrintQueryViewDelegate> delegate;
}

@property (nonatomic,assign) id<PrintQueryViewDelegate> delegate;


@end