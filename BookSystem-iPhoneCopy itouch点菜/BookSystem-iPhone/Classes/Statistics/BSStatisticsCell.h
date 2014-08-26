//
//  BSStatisticsCell.h
//  BookSystem-iPhone
//
//  Created by Stan Wu on 13-1-10.
//  Copyright (c) 2013年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BSStatisticsCell : UITableViewCell{
    UIImageView *imgvDone,*imgvLeft;
    UILabel *lblDone,*lblLeft;
    UILabel *lblTitle,*lblStatus;
    
    NSDictionary *dicInfo;
}
@property (nonatomic,retain) NSDictionary *dicInfo;

@end
