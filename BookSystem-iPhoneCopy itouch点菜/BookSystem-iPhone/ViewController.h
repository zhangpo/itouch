//
//  ViewController.h
//  BookSystem-iPhone
//
//  Created by Stan Wu on 12-11-17.
//  Copyright (c) 2012年 Stan Wu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CVLocalizationSetting.h"

@interface ViewController : UIViewController<UIAlertViewDelegate>{
    UILabel *lblCommandString;
    CVLocalizationSetting *langSetting;
    NSDictionary *dicUserCode;
    NSString *posVersion;
}
- (void)showCommandString;

@end
