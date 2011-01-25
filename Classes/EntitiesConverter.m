//
//  EntitiesConverter.m
//  ipttu
//
//  Created by Víctor R. Ruiz on 30/08/10.
//  Copyright 2010 European Southern Observatory & Víctor R. Ruiz. All rights reserved.
//
//  Snippet: http://stackoverflow.com/questions/659602/objective-c-html-escape-unescape

#import "EntitiesConverter.h"

@implementation EntitiesConverter

@synthesize resultString;

- (id)init
{
	if([super init]) {
		resultString = [[NSMutableString alloc] init];
	}
	return self;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)s {
	[self.resultString appendString:s];
}

- (NSString*)convertEntiesInString:(NSString*)s {
	if(s == nil) {
		NSLog(@"ERROR : Parameter string is nil");
	}
	[resultString setString:@""]; // Fix for later callings
	NSString* xmlStr = [NSString stringWithFormat:@"<d>%@</d>", s];
	NSData *data = [xmlStr dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	NSXMLParser* xmlParse = [[NSXMLParser alloc] initWithData:data];
	[xmlParse setDelegate:self];
	[xmlParse parse];
	NSString* returnStr = [[NSString alloc] initWithFormat:@"%@",resultString];
	return [returnStr autorelease];
}

- (void)dealloc {
	[resultString release];
	[super dealloc];
}

@end