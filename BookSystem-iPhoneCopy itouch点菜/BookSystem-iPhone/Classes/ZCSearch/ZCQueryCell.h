//
//  BSQueryCell.h
//  BookSystem
//
//  Created by Dream on 11-5-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ZCQueryCell : UITableViewCell {
    UILabel *lblName,*lblCount,*lblUnit,*lblPrice,*lblTotalPrice,*lblAddition;
    
    NSDictionary *dicInfo;
    BOOL bSelected;
}
@property BOOL bSelected;
@property (nonatomic,retain) NSDictionary *dicInfo;


@end
