//
//  SWDataToolKit.m
//  SWToolKit
//
//  Created by Wu Stan on 12-7-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SWDataToolKit.h"
#import "SWUIToolKit.h"

@implementation NSString(SWExtensions)

/*
- (CGSize)sizeWithFont:(UIFont *)font width:(CGFloat)width{
    MarkupParser *p = [[MarkupParser alloc] init];
    NSAttributedString *attString = [p attrStringFromMarkup:self];
    [p release];
    int i = 0;
    CGSize size;
    BOOL needHeight = YES;
    while (needHeight) {
        i++;
        size = CGSizeMake(width, [self sizeWithFont:font].height*i);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0, 0, size.width, size.height));
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attString length]), path, NULL);
        if (CTFrameGetVisibleStringRange(frame).length>=attString.length)
            needHeight = NO;
        CFRelease(path);
        CFRelease(framesetter);
        CFRelease(frame);
        
        if (!needHeight){
            if (1==i){
                BOOL needWidth = YES;
                float w = 0;
                while (needWidth) {
                    w++;
                    size = CGSizeMake(w, [self sizeWithFont:font].height);
                    CGMutablePathRef path = CGPathCreateMutable();
                    CGPathAddRect(path, NULL, CGRectMake(0, 0, size.width, size.height));
                    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
                    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [attString length]), path, NULL);
                    if (CTFrameGetVisibleStringRange(frame).length>=attString.length)
                        needWidth = NO;
                    CFRelease(path);
                    CFRelease(framesetter);
                    CFRelease(frame);
                }
            }
        }
    }
    
    return size;
}
 */

- (NSString *)documentPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:self];
    
    return path;
}

- (NSString *)fileName{
    NSArray *ary = [self componentsSeparatedByString:@"/"];
    NSMutableString *fileName = [NSMutableString string];
    
    for (int i=0;i<[ary count];i++)
        [fileName appendString:[ary objectAtIndex:i]];
    
    return fileName;
}

- (int)indexInString:(NSString *)str{
    int dret = 0;
    NSArray *ary = [str componentsSeparatedByString:@","];
    for (int i=0;i<ary.count;i++){
        if ([self isEqualToString:[ary objectAtIndex:i]])
            dret = i;
    }
    
    return dret;
}

- (NSString *)hostName{
    //  @"ftp://shipader:shipader123@61.174.28.122/BookSystem/"
    
    NSString *str = [[[[self componentsSeparatedByString:@"://"] objectAtIndex:1] componentsSeparatedByString:@"/"] objectAtIndex:0];
    NSArray *ary = [str componentsSeparatedByString:@"@"];
    if (1==ary.count)
        return str;
    else
        return [ary objectAtIndex:1];
}

- (NSDictionary *)account{
    NSString *str = [[[[self componentsSeparatedByString:@"://"] objectAtIndex:1] componentsSeparatedByString:@"/"] objectAtIndex:0];
    NSArray *ary = [str componentsSeparatedByString:@"@"];
    if (1==ary.count)
        return nil;
    else{
        NSString *strinfo = [ary objectAtIndex:0];
        ary = [strinfo componentsSeparatedByString:@":"];
        if (ary.count==2){
            return [NSDictionary dictionaryWithObjectsAndKeys:[ary objectAtIndex:0],@"username",[ary objectAtIndex:1],@"password",nil];
        }else
            return nil;
        
    }
    
}

#ifdef InAiBa

+ (NSString *)areaForProvince:(NSString *)province city:(NSString *)city{
    int dProvince = [province intValue];
    int dCity = [city intValue];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ProfileInfo.plist" ofType:nil];
    NSDictionary *dicProfilePlist = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *arycities = [dicProfilePlist objectForKey:@"cities"];
    NSArray *aryprovinces = [dicProfilePlist objectForKey:@"provinces"];
    NSString *strprovince = [aryprovinces objectAtIndex:dProvince];
    NSString *strcity = [arycities objectAtIndex:dCity];
    if (0==dCity)
        strcity = @"";
    
    return [strprovince stringByAppendingString:strcity];
}

#endif

@end
