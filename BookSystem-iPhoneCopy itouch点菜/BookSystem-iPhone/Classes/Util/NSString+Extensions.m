//
//  NSString+Extensions.m
//  AiBa
//
//  Created by Wu Stan on 11-9-27.
//  Copyright 2011年 CheersDigi. All rights reserved.
//

#import "NSString+Extensions.h"

@implementation NSString (NSString_Extensions)

-(NSString *)URLEncode
{
	NSString *str = nil;
    //	$entities = array('%21', '%2A', '%27', '%28', '%29', '%3B', '%3A', '%40', '%26', '%3D', '%2B', '%24', '%2C', '%2F', '%3F', '%25', '%23', '%5B', '%5D');
    //	$replacements = array('!', '*', "'", "(", ")", ";", ":", "@", "&", "=", "+", "$", ",", "/", "?", "%", "#", "[", "]");
	NSArray *replaceArray = [NSArray arrayWithObjects:@"!",@"*",@"'",@"(",@")",@";",@":",@"@",@"&",@"=",@"+",@"$",@",",@"/",@"?",@"%",@"#",@"[",@"]",@" ",@"\"",nil];
	NSArray *codeArray = [NSArray arrayWithObjects:@"%21",@"%2A",@"%27",@"%28",@"%29",@"%3B",@"%3A",@"%40",@"%26",@"%3D",
						  @"%2B",@"%24",@"%2C",@"%2F",@"%3F",@"%25",@"%23",@"%5B",@"%5D",@"%20",@"%22",nil];
    //	NSLog(@"decoded:%@",self);
	str = [self stringByReplacingOccurrencesOfString:[replaceArray objectAtIndex:15] withString:[codeArray objectAtIndex:15]];
	for(int i=0;i<21;i++)
	{
		if(15!=i)
			str = [str stringByReplacingOccurrencesOfString:[replaceArray objectAtIndex:i] withString:[codeArray objectAtIndex:i]];
	}
    
    //	NSLog(@"encoded:%@",str);
	return str;
}

- (BOOL)isValidEmailAddress{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

@end
