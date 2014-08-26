//
//  CaiDanListCell.h
//  BookSystem
//
//  Created by sundaoran on 13-12-9.
//
//

#import <UIKit/UIKit.h>
#import "AKsCanDanListClass.h"
#import "AKsYouHuiListClass.h"

@interface CaiDanListCell : UITableViewCell

-(void)setCellForArray:(AKsCanDanListClass *)caidan;

-(void)setCellForAKsYouHuiList:(AKsYouHuiListClass *)list;

@end
