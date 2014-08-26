//
//  BoarkCell.h
//  BookSystem-iPhone
//
//  Created by dcw on 14-3-27.
//  Copyright (c) 2014年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BoarkCell : UITableViewCell{
    UILabel *lblName,*lblShiji,*lblYuGu,*lblWanC;
}

@property(nonatomic,assign)NSDictionary *dicInfo;

@end
