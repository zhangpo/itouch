//
//  NSString+Encrypt.m
//  CapitalVueHD
//
//  Created by Dream on 10-12-3.
//  Copyright 2010 SmilingMobile. All rights reserved.
//

#import "NSString+Encrypt.h"



@implementation NSString(Encrypt)

static char base64EncodingTable[64] = {
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
	'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
	'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
	'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};

-(NSString *)MD5
{
	unsigned char hashBytes[CC_MD5_DIGEST_LENGTH];
	CC_MD5([self UTF8String], [self length], hashBytes);
	
//	for (int i=0;i<CC_MD5_DIGEST_LENGTH;i++)
//		printf("%x",hashBytes[i]);

	NSMutableString *mutStr = [[NSMutableString alloc] init];
	for(int i=0;i<CC_MD5_DIGEST_LENGTH;i++)
	{
		NSString *a = [NSString stringWithFormat:@"%02x",hashBytes[i]];
		[mutStr appendString:a];
	}
	
	return [mutStr autorelease];
}


-(NSString *)HMAC:(NSString *)Alg key:(NSString *)key;
{
	NSMutableString *mutStr = [[NSMutableString alloc] init];
	if([Alg isEqualToString:@"md5"]){
		unsigned char hmacBytes[CC_MD5_DIGEST_LENGTH];
		CCHmac(kCCHmacAlgMD5, [key UTF8String], [key length], [self UTF8String], [self length], hmacBytes);
		for(int i=0;i<CC_MD5_DIGEST_LENGTH;i++)
		{
			NSString *a = [NSString stringWithFormat:@"%02x",hmacBytes[i]];
			[mutStr appendString:a];
		}
	}
	else if([Alg isEqualToString:@"sha1"]){
		unsigned char hmacBytes[CC_SHA1_DIGEST_LENGTH];
		CCHmac(kCCHmacAlgSHA1, [key UTF8String], [key length], [self UTF8String], [self length], hmacBytes);
		for(int i=0;i<CC_SHA1_DIGEST_LENGTH;i++)
		{
			NSString *a = [NSString stringWithFormat:@"%02x",hmacBytes[i]];
			[mutStr appendString:a];
		}
	}
	else if([Alg isEqualToString:@"sha256"]){
		unsigned char hmacBytes[CC_SHA256_DIGEST_LENGTH];
		CCHmac(kCCHmacAlgSHA256, [key UTF8String], [key length], [self UTF8String], [self length], hmacBytes);
		for(int i=0;i<CC_SHA256_DIGEST_LENGTH;i++)
		{
			NSString *a = [NSString stringWithFormat:@"%02x",hmacBytes[i]];
			[mutStr appendString:a];
		}
	}
	else if([Alg isEqualToString:@"sha512"]){
		unsigned char hmacBytes[CC_SHA512_DIGEST_LENGTH];
		CCHmac(kCCHmacAlgSHA512, [key UTF8String], [key length], [self UTF8String], [self length], hmacBytes);
		for(int i=0;i<CC_SHA512_DIGEST_LENGTH;i++)
		{
			NSString *a = [NSString stringWithFormat:@"%02x",hmacBytes[i]];
			[mutStr appendString:a];
		}
	}
	return [mutStr autorelease];
}

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

+(NSString *)HTTPQuery:(NSDictionary *)parameters
{
	NSMutableString *str = [[NSMutableString alloc] init];
	NSArray *allKeys = [parameters allKeys];
	for(NSString *key in allKeys)
	{
		[str appendString:[NSString stringWithFormat:@"%@=%@&amp;",key,[[parameters objectForKey:key] URLEncode]]];
	}
	return [str autorelease];
}





+ (NSString *) base64StringFromData: (NSData *)data length: (int)length {
	unsigned long ixtext, lentext;
	long ctremaining;
	unsigned char input[3], output[4];
	short i, charsonline = 0, ctcopy;
	const unsigned char *raw;
	NSMutableString *result = nil;
	
	lentext = [data length]; 
	if (lentext < 1)
		return @"";
	result = [NSMutableString stringWithCapacity: lentext];
	raw = [data bytes];
	ixtext = 0; 
	
	while (true) 
	{
		ctremaining = lentext - ixtext;
		if (ctremaining <= 0) 
			break;        
		for (i = 0; i < 3; i++)
		{ 
			unsigned long ix = ixtext + i;
			if (ix < lentext)
				input[i] = raw[ix];
			else
				input[i] = 0;
		}
		output[0] = (input[0] & 0xFC) >> 2;
		output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
		output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
		output[3] = input[2] & 0x3F;
		ctcopy = 4;
		switch (ctremaining)
		{
			case 1: 
				ctcopy = 2; 
				break;
			case 2: 
				ctcopy = 3; 
				break;
		}
		
		for (i = 0; i < ctcopy; i++)
			[result appendString: [NSString stringWithFormat: @"%c", base64EncodingTable[output[i]]]];
		
		for (i = ctcopy; i < 4; i++)
			[result appendString: @"="];
		
		ixtext += 3;
		charsonline += 4;
		
		if ((length > 0) && (charsonline >= lentext))
			charsonline = 0;
		
        break;
	}
    return result;
}

static char base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

- (NSString *)newStringInBase64FromData
{
	NSMutableString *dest = [[NSMutableString alloc] init];
	NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
	unsigned char * working = (unsigned char *)[data bytes];
	int srcLen = [data length];
	
	// tackle the source in 3's as conveniently 4 Base64 nibbles fit into 3 bytes
	for (int i=0; i<srcLen; i += 3)
	{
		// for each output nibble
		for (int nib=0; nib<4; nib++)
		{
			// nibble:nib from char:byt
			int byt = (nib == 0)?0:nib-1;
			int ix = (nib+1)*2;
			
			if (i+byt >= srcLen) break;
			
			// extract the top bits of the nibble, if valid
			unsigned char curr = ((working[i+byt] << (8-ix)) & 0x3F);
			
			// extract the bottom bits of the nibble, if valid
			if (i+nib < srcLen) curr |= ((working[i+nib] >> ix) & 0x3F);
			
			[dest appendFormat:@"%c", base64[curr]];
		}
	}
	
	return [dest autorelease];
}
@end
