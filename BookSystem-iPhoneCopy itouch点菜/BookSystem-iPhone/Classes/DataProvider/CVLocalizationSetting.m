//
//  CVLocalizationSetting.m
//  CV-iphone
//
//  Created by Stan on 10-12-20.
//  Copyright 2010 SmilingMobile. All rights reserved.
//

#import "CVLocalizationSetting.h"


@implementation CVLocalizationSetting

static CVLocalizationSetting  *sharedInstance = nil;

static NSDictionary *settingDict = nil;

+ (CVLocalizationSetting *)sharedInstance {
    @synchronized(self) {
        if (sharedInstance==nil) {
            sharedInstance = [[super allocWithZone:NULL] init];
   //         [[self alloc] init]; // assignment not done here
			NSString *path = [[NSBundle mainBundle] pathForResource:@"CVLocalizationSetting.plist" ofType:nil];
			
			settingDict = [[NSDictionary alloc] initWithContentsOfFile:path];
			
			NSString *switchCode = nil;
			NSDictionary *dict;

			switchCode = [[NSUserDefaults standardUserDefaults] stringForKey:@"language"];

				if ([switchCode isEqualToString:@"en"])
					dict = [[NSDictionary alloc] initWithDictionary:[settingDict objectForKey:@"English"]];
				else if ([switchCode isEqualToString:@"cn"])
					dict = [[NSDictionary alloc] initWithDictionary:[settingDict objectForKey:@"Chinese"]];
                else{
                    dict = [[NSDictionary alloc] initWithDictionary:[settingDict objectForKey:@"Traditional"]];
                }


			[settingDict release];
			settingDict = dict;

        }
    }
    return sharedInstance;
}


+ (id)allocWithZone:(NSZone *)zone {
//    @synchronized(self) {
//        if (sharedInstance == nil) {
//            sharedInstance = [super allocWithZone:zone];
//            return sharedInstance;  // assignment and return on first allocation
//        }
//    }
//    return nil; //on subsequent allocation attempts return nil
    return [[self sharedInstance] retain];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}

- (oneway void)release {
	
}

- (id)autorelease {
    return self;
}



#pragma mark -
#pragma mark Data Provider
//return langCode
-(NSString *)localizedString:(NSString *)str;{
    NSString *strstr = [settingDict objectForKey:str];
    if (!strstr)
        strstr = str;
	return strstr;
}
	


-(NSArray *)getTabBarTitles{
	return	[settingDict objectForKey:@"TabBarTitles"];
}

-(NSArray *)getNewsFirstList{
	return [settingDict objectForKey:@"NewsFirstList"];
}

-(NSArray *)getMacroNaviItems{
	return [settingDict objectForKey:@"MacroNaviItems"];
}

-(UIColor *)getColor:(NSString *)name{
	NSString *strColor = [[settingDict objectForKey:@"Color"] objectForKey:name];
	NSArray *colorArray = [strColor componentsSeparatedByString:@","];
	
	float fRed = [[colorArray objectAtIndex:0] floatValue];
	float fGreen = [[colorArray objectAtIndex:1] floatValue];
	float fBlue = [[colorArray objectAtIndex:2] floatValue];
	float fAlpha = [[colorArray objectAtIndex:3] floatValue];
	
	return [UIColor colorWithRed:fRed green:fGreen blue:fBlue alpha:fAlpha];
}
@end
