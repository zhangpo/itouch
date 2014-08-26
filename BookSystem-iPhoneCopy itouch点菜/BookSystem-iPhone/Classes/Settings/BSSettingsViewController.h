//
//  BSSettingsViewController.h
//  BookSystem-iPhone
//
//  Created by Stan Wu on 12-12-1.
//  Copyright (c) 2012年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CVLocalizationSetting.h"

@interface BSSettingsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>{
    UITableView *tvSettings;
    
    NSMutableDictionary *dicInfo;
    CVLocalizationSetting *langSetting;
    NSInteger   _index;
}
@property (nonatomic,retain) NSMutableDictionary *dicInfo;

@end
