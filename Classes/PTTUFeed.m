//
//  PTTUFeed.m
//  ipttu
//
//  Created by Víctor R. Ruiz on 30/08/10.
//  Copyright 2010 European Southern Observatory & Víctor R. Ruiz. All rights reserved.
//

#import "PTTUFeed.h"
#import "EntitiesConverter.h"
#import "UIImageExtras.h"

@implementation PTTUFeed

@synthesize stories;

- (id) init {
	if (self = [super init]) {
		stories = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)parseXMLFileAtURL:(NSString *)URL
{	
    NSURL *xmlURL = [NSURL URLWithString:URL];
	NSData *data = [[NSData alloc] initWithContentsOfURL:xmlURL];
    rssParser = [[NSXMLParser alloc] initWithData:data];
    [rssParser setDelegate:self];
	
    [rssParser setShouldProcessNamespaces:NO];
    [rssParser setShouldReportNamespacePrefixes:NO];
    [rssParser setShouldResolveExternalEntities:NO];
	
	[data release];
    [rssParser parse];
}

- (void)parse:(NSString *)feedURL {
	// Parses URL
	if (feedURL != nil) [self parseXMLFileAtURL:feedURL];	
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSString *errorString = [NSString stringWithFormat:@"Unable to download story feed from web site (Error code %i )", [parseError code]];
	NSLog(@"error parsing XML: %@", errorString);
	
	UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading content" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
	[errorAlert release];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{			
    // NSLog(@"didStartElement: %@", elementName);
	currentElement = [elementName copy];
	if ([elementName isEqualToString:@"item"]) {
		// 
		item = [[NSMutableDictionary alloc] init];
		currentTitle = [[NSMutableString alloc] init];
		currentDate = [[NSMutableString alloc] init];
		currentSummary = [[NSMutableString alloc] init];
		currentLink = [[NSMutableString alloc] init];
		currentEnclosure = [[NSMutableString alloc] init];
		currentCreator = [[NSMutableString alloc] init];
	} else if ([elementName isEqualToString:@"enclosure"]) {
		currentEnclosure = [[attributeDict objectForKey:@"url"] copy];
		currentEnclosureType = [[attributeDict objectForKey:@"type"] copy];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{     
	// NSLog(@"didEndElement: %@", elementName);
	if ([elementName isEqualToString:@"item"]) {

		// Entities converter
		EntitiesConverter *converter = [[EntitiesConverter alloc] init];
		NSString *title = [converter convertEntiesInString:currentTitle];
		NSString *summary = [converter convertEntiesInString:currentSummary];
		
		// Date conversion
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"];
		NSDate *myDate = [dateFormatter dateFromString:currentDate];
		NSDateFormatter *format = [[NSDateFormatter alloc] init];
		[format setDateFormat:@"d MMM yyyy, HH:mm"];
		NSString *date = [format stringFromDate:myDate];
		[format setDateFormat:@"d MMM"];
		NSString *shortDate = [format stringFromDate:myDate];

		[format release];
		[dateFormatter release];
		
		// Store item
		[item setObject:title forKey:@"title"];
		[item setObject:currentLink forKey:@"link"];
		[item setObject:currentEnclosureType forKey:@"enclosureType"];
		[item setObject:summary forKey:@"summary"];
		[item setObject:currentCreator forKey:@"dc:creator"];
		if (date) {
			[item setObject:date forKey:@"date"];
		} else {
			[item setObject:currentDate forKey:@"date"];
		}
		if (shortDate) {
			[item setObject:shortDate forKey:@"shortDate"];
		} else {
			[item setObject:currentDate forKey:@"shortDate"];
		}
		[item setObject:currentEnclosure forKey:@"enclosure"];
		[item setObject:currentEnclosureType forKey:@"enclosureType"];
		if (currentLinkImage) [item setObject:currentLinkImage forKey:@"linkImage"];
		[stories addObject:item];
		NSLog(@"Parser. Adding story: %@", currentTitle);

		// Release
		[converter release];
	}
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
	// Save the characters for the current item
	if ([currentElement isEqualToString:@"title"]) {
		[currentTitle appendString:string];
	} else if ([currentElement isEqualToString:@"link"]) {
		[currentLink appendString:string];
	} else if ([currentElement isEqualToString:@"description"]) {
		[currentSummary appendString:string];
	} else if ([currentElement isEqualToString:@"pubDate"]) {
		[currentDate appendString:string];
	} else if ([currentElement isEqualToString:@"dc:creator"]) {
		[currentCreator appendString:string];
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	// NSLog(@"parserDidEndDocument: Stories array has %d items", [stories count]);
	[currentElement release];
	[rssParser release];
	[item release];
	[currentTitle release];
	[currentDate release];
	[currentSummary release];
	[currentLink release];
	[currentEnclosure release];
	[currentEnclosureType release];
	[currentLinkImage release];
	[currentCreator release];
}

- (void) dealloc {
	[stories release];
	
	// Super dealloc
	[super dealloc];
}

@end
