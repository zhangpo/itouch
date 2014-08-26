//
//  NSDictionary+Extensions.m
//  AiBa
//
//  Created by Wu Stan on 11-10-19.
//  Copyright 2011年 CheersDigi. All rights reserved.
//

#import "NSDictionary+Extensions.h"
#import "NSString+Extensions.h"


@implementation NSDictionary (NSDictionary_Extensions)


- (CGFloat)heightForStatus{
    float len = 245;

    CGSize size;
    
    NSString *strContent = [self objectForKey:@"content"];
    size = [strContent sizeWithFont:kContentFont constrainedToSize:CGSizeMake(len, 1000)];

    
    float h = size.height+55;
    
    
    NSString *strPicture = [self objectForKey:@"picture"];
    if (strPicture && [strPicture length]>0)
        h += 90;
    
    if (![self objectForKey:@"platform"] && ![self objectForKey:@"comment_count"] && ![self objectForKey:@"distributions"]){
        h -= 20;
    }
    
    if ([[self objectForKey:@"comment_count"] intValue]>0)
        h += 53;
    
    if (h<=56)
        h = 56;
    
    return h;
}

- (CGFloat)heightForCommentMe{
    BOOL hasImage = ([self objectForKey:@"origin_picture"] && [[self objectForKey:@"origin_picture"] length]>0);
    float len = 254;
    float lines;
    CGSize size;
    
    NSString *strContent = [self objectForKey:@"content"];
    size = [strContent sizeWithFont:kContentFont];
    lines = floorf(size.width/len+0.5f)+1;
    
    float h = size.height*lines+50;
    
    
    NSString *retweet = nil;
    if (hasImage)
        retweet = [NSString stringWithFormat:@"@%@:%@...",[self objectForKey:@"origin_nickname"],[self objectForKey:@"origin_content"]];
    else
        retweet = [NSString stringWithFormat:@"@%@:%@",[self objectForKey:@"origin_nickname"],[self objectForKey:@"origin_content"]];
    
    size = [retweet sizeWithFont:kContentFont];
    lines = floorf(size.width/(len-18)+0.5f)+1;
    //        h += 5;
    h += lines*size.height + 14;
    
//    h += 5;
    
    h -= 20;
    
    
    if (h<=56)
        h = 56;
    
    return h;
}

- (CGFloat)heightForPM{
    float h = 0;

    NSString *content = [self objectForKey:@"content"];
    CGSize size = [content sizeWithFont:kPMFont constrainedToSize:CGSizeMake(kPMCellContentWidth, 2000)];
    h += size.height;
    
    h += 24;
    
    if (h<40)
        h = 40;
    
    h += 5;
    
    return h;
}


- (NSString *)addUrl:(NSString *)strText{
    NSString *result = strText;
    
    //    NSArray *ary = [strText componentsSeparatedByString:@"@"];
    
    NSString *substring = strText;
    
    NSRange range;
    
    while ([substring rangeOfString:@"http://" options:NSCaseInsensitiveSearch].location!=NSNotFound) {
        range = [substring rangeOfString:@"http://" options:NSCaseInsensitiveSearch];
        if (range.location<[strText length]-7){
            substring = [substring substringFromIndex:range.location+7];
            NSString *strUrl = [[substring componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" （）。，：():,[]{}'\"“”"]] objectAtIndex:0];
            
            int cnindex = 0;
            for (int i=0;i<[strUrl length];i++){
                if ([strUrl characterAtIndex:i]>128){
                    cnindex = i;
                    break;
                }
            }
            
            if (cnindex!=0)
                strUrl = [strUrl substringToIndex:cnindex];
            
            
            
            result = [result stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"http://%@",strUrl] withString:@"shoturl" options:NSCaseInsensitiveSearch range:NSRangeFromString([NSString stringWithFormat:@"{0,%d}",[result length]])];
            result = [result stringByReplacingOccurrencesOfString:@"shoturl"  withString:[NSString stringWithFormat:@"<a href='web://%@'>http://%@</a>",[strUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],strUrl]];
        }
        else
            break;
    }
    
    substring = result;
    while ([substring rangeOfString:@"@"].location!=NSNotFound) {
        range = [substring rangeOfString:@"@"];
        if (range.location<[strText length]-1){
            substring = [substring substringFromIndex:range.location+1];
            NSString *strAt = [[substring componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" （）。，：():,[]{}'\"“”"]] objectAtIndex:0];
            result = [result stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"@%@",strAt] withString:@"atsomeone"];
            result = [result stringByReplacingOccurrencesOfString:@"atsomeone"  withString:[NSString stringWithFormat:@"<a href='profile://aiba.com/%@'>@%@</a>",[strAt stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],strAt]];
        }else
            break;
    }
    
    return result;
}

- (NSString *)dateString{
    NSDate *created_date = [NSDate dateWithTimeIntervalSince1970:[[self objectForKey:@"dateline"] doubleValue]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    
    
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strDate = [formatter stringFromDate:created_date];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *date1 = [formatter stringFromDate:created_date];
    NSString *date2 = [formatter stringFromDate:[NSDate date]];
    if ([date1 isEqualToString:date2]){
        [formatter setDateFormat:@"HH:mm"];
        
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:created_date];
        if (timeInterval>3600){
            strDate = [formatter stringFromDate:created_date];
            strDate = [NSString stringWithFormat:@"%@ %@",@"今天",strDate];
        }
        else{
            strDate = [NSString stringWithFormat:@"%d分钟前",(int)(timeInterval/60)];
        }        
    }else {
        [formatter setDateFormat:@"yyyy-MM-dd 00:00"];
        NSDate *tempdate = [formatter dateFromString:[formatter stringFromDate:[NSDate date]]];
        if ([tempdate timeIntervalSinceDate:created_date]<3600*24){
            [formatter setDateFormat:@"HH:mm"];
            strDate = [formatter stringFromDate:created_date];
            strDate = [NSString stringWithFormat:@"%@ %@",@"昨天",strDate];
        }else{
            [formatter setDateFormat:@"yyyy"];
            date1 = [formatter stringFromDate:created_date];
            date2 = [formatter stringFromDate:[NSDate date]];
            
            if ([date1 isEqualToString:date2]){
                [formatter setDateFormat:@"MM-dd HH:mm"];
                strDate = [formatter stringFromDate:created_date];
            }
        }
    }
    
    [formatter release];
    
    return strDate;
}

- (NSString *)htmlString{
    NSDictionary *origin = self;
    
    BOOL bRetweet = (BOOL)[self objectForKey:@"origin"];
    NSDictionary *retweet = nil;
//    bRetweet = NO;
    if (bRetweet){
//        NSMutableDictionary *mutdict = [NSMutableDictionary dictionary];
//        for (NSString *key in self.allKeys){
//            if ([key rangeOfString:@"origin"].location!=NSNotFound){
//                NSString *newkey = [key stringByReplacingOccurrencesOfString:@"origin" withString:@""];
//                newkey = [newkey stringByReplacingOccurrencesOfString:@"_" withString:@""];
//                [mutdict setObject:[self objectForKey:key] forKey:newkey];
//            }
//        }
//        if ([mutdict.allKeys count]>0)
//            retweet = [NSDictionary dictionaryWithDictionary:mutdict];
        retweet = [self objectForKey:@"origin"];
    }
    
    NSString *strSource = [[self objectForKey:@"platform"] intValue]<=1?@"来自网页版":([[self objectForKey:@"platform"] intValue]==2?@"来自iPhone客户端":@"来自Android客户端");
    NSMutableString *strMut = [NSMutableString string];
    if (retweet){
        //original text
        [strMut appendFormat:@"<div class=\"content_text\">%@</div>",[self addUrl:[origin objectForKey:@"content"]]];
        [strMut appendString:@"<div class=\"pop_top\"></div><div class=\"pop_middle\">"];
        //retweet text
        [strMut appendString:[self addUrl:[NSString stringWithFormat:@"@%@:%@",[retweet objectForKey:@"nickname"],[retweet objectForKey:@"content"]]]];
        //retweet image
        if ([retweet objectForKey:@"picture"] && [[retweet objectForKey:@"picture"] length]>0)
            [strMut appendFormat:@"<div id=\"content_pic\"><img id=\"img_loading\" src =\"pic_loading.gif\" width=\"72\" height=\"69\"/><a href=\"pic://%@\"><span id=\"contant_pic\"> <img id=\"img_weibo\" style=\"display:none\" onload='javascript:document.getElementById(\"img_loading\").style.display=\"none\";document.getElementById(\"img_weibo\").style.display=\"block\";' onerror='javascript:document.getElementById(\"img_loading\").style.display=\"none\";' src=\"%@\" /></span></a></div>",[[retweet objectForKey:@"picture"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[retweet objectForKey:@"picture"]];
        [strMut appendString:@"</div><div class=\"pop_bottom\"></div><p>&nbsp; </p>"];
        
        
        [strMut appendFormat:@"<p>%@<span>%@</span></p>",[self dateString],strSource];
    }else{
        [strMut appendString:[self addUrl:[origin objectForKey:@"content"]]];
        if ([origin objectForKey:@"picture"] && [[origin objectForKey:@"picture"] length]>0)
            [strMut appendFormat:@"<div id=\"content_pic\"><img id=\"img_loading\" src =\"pic_loading.gif\" width=\"72\" height=\"69\"/><a href=\"pic://%@\"><span id=\"contant_pic\"><img id=\"img_weibo\" style=\"display:none\" onload='javascript:document.getElementById(\"img_loading\").style.display=\"none\";document.getElementById(\"img_weibo\").style.display=\"block\";' onerror='javascript:document.getElementById(\"img_loading\").style.display=\"none\";'  src=\"%@\" /></span></a></div>",[[origin objectForKey:@"picture"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[origin objectForKey:@"picture"]];
        [strMut appendString:@"<p>&nbsp; </p>"];
        
        
        [strMut appendFormat:@"<p>%@<span>%@</span></p>",[self dateString],strSource];
    }
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"detail.html" ofType:nil];
    NSString *strDetail = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];    
    NSString *ret = [NSString stringWithFormat:strDetail,strMut];
    
    return ret;
    
}


@end
