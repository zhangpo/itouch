//
//  NSDictionary+Extensions.h
//  AiBa
//
//  Created by Wu Stan on 11-10-19.
//  Copyright 2011年 CheersDigi. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kContentFont        [UIFont systemFontOfSize:14]
#define kPMFont             [UIFont systemFontOfSize:16]
#define kPMCellContentWidth     165.0f

@interface NSDictionary (NSDictionary_Extensions)


- (CGFloat)heightForStatus;
- (CGFloat)heightForPM;
- (CGFloat)heightForCommentMe;
- (NSString *)htmlString;
- (NSString *)dateString;

@end
