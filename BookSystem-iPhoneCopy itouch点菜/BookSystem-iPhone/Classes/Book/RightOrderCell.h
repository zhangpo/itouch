//
//  RightOrderCell.h
//  BookSystem-iPhone
//
//  Created by dcw on 14-1-24.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RightOrderCell : UITableViewCell{
    NSDictionary *dicInfo;
    UILabel *lblName,*lblTotal;
}
@property (nonatomic,retain)NSDictionary *dicInfo;
@end
