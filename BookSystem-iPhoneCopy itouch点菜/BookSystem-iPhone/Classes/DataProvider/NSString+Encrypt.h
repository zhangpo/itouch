//
//  NSString+Encrypt.h
//  CapitalVueHD
//
//  Created by Dream on 10-12-3.
//  Copyright 2010 SmilingMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSString(Encrypt)

-(NSString *)MD5;
-(NSString *)HMAC:(NSString *)Alg key:(NSString *)key;
-(NSString *)URLEncode;
+(NSString *)HTTPQuery:(NSDictionary *)parameters;
+(NSString *)base64StringFromData:(NSData *)data length:(int)length;
- (NSString *)newStringInBase64FromData;
@end
