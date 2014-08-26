//
//  WaitCell.h
//  BookSystem-iPhone
//
//  Created by dcw on 14-2-7.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaitCell : UITableViewCell{
    UILabel *lblPhone,*lblCode;
}
@property (nonatomic,assign)NSDictionary *dicInfo;

@end
