//
//  NSDataExtras.m
//  ipttu
//
//  Created by Víctor R. Ruiz on 04/09/10.
//  Copyright 2010 European Southern Observatory & Víctor R. Ruiz. All rights reserved.
//
//  Snippet: http://iphonesdksnippets.com/post/2010/02/16/Get-MD5-hash-from-NSData.aspx

#import "NSDataExtras.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (Md5)

-(NSString*)md5{
	const char *cStr = [self bytes];
	unsigned char digest[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, [self length], digest );
	NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
				   digest[0], digest[1], 
				   digest[2], digest[3],
				   digest[4], digest[5],
				   digest[6], digest[7],
				   digest[8], digest[9],
				   digest[10], digest[11],
				   digest[12], digest[13],
				   digest[14], digest[15]];
	return s;
	
}

@end