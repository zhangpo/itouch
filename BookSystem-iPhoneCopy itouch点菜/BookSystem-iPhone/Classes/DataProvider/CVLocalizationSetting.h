//
//  CVLocalizationSetting.h
//  CV-iphone
//
//  Created by Stan on 10-12-20.
//  Copyright 2010 SmilingMobile. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CVLocalizationSetting : NSObject {

}
+(CVLocalizationSetting *)sharedInstance;
-(NSString *)localizedString:(NSString *)str;
-(NSArray *)getNewsFirstList;
-(NSArray *)getTabBarTitles;
-(NSArray *)getMacroNaviItems;
-(UIColor *)getColor:(NSString *)name;
@end
