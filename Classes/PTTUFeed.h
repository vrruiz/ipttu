//
//  PTTUFeed.h
//  ipttu
//
//  Created by Víctor R. Ruiz on 30/08/10.
//  Copyright 2010 European Southern Observatory & Víctor R. Ruiz. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PTTUFeed : NSObject <NSXMLParserDelegate> {
	NSXMLParser *rssParser;
	NSMutableArray *stories;
	NSMutableDictionary *item;
	NSString *currentElement;
	NSMutableString *currentTitle, *currentDate, *currentSummary, *currentLink;
	NSMutableString *currentEnclosure, *currentEnclosureType, *currentLinkImage;
	NSMutableString *currentCreator;
}

- (id) init;
- (void)parse: (NSString *)feedURL;
- (void)dealloc;

@property (retain) NSMutableArray *stories;

@end
