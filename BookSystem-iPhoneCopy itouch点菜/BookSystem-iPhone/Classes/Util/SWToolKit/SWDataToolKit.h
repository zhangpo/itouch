//
//  SWDataToolKit.h
//  SWToolKit
//
//  Created by Wu Stan on 12-7-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

#pragma mark -
#pragma mark NSDictionary Extensions
//@interface NSDictionary(CoreTextExtension)
//
//- (CGSize)sizeOf;
//
//@end
#define InAiBa

#pragma mark -
#pragma mark NSString Extensions
@interface NSString(SWExtensions)

- (CGSize)sizeWithFont:(UIFont *)font width:(CGFloat)width;
- (NSString *)documentPath;
- (NSString *)fileName;
- (int)indexInString:(NSString *)str;
- (NSString *)hostName;
- (NSDictionary *)account;

#ifdef InAiBa

+ (NSString *)areaForProvince:(NSString *)province city:(NSString *)city;

#endif

@end


