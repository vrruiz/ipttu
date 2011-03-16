//
//  PTTUFeedDownloader.m
//  ipttu
//
//  Created by Víctor R. Ruiz on 23/02/11.
//  Copyright 2011 European Southern Observatory & Víctor R. Ruiz. All rights reserved.
//

#import "PTTUFeedDownloader.h"
#import "PTTUFeed.h"

@implementation PTTUFeedDownloader

@synthesize stories;
@synthesize feedUrl;
@synthesize lastUpdated;
@synthesize delegate;

- (id)initWithUrl:(NSString *)url {
    self = [super init];
    if (self) {
        // Custom initialization
		self.stories = nil;
		self.feedUrl = url;
        self.lastUpdated = nil;
    }
    return self;	
}

#pragma mark -
#pragma mark Feed download

- (void) backgroundFeed {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	PTTUFeed *pttuFeed = [[PTTUFeed alloc] init];
	[pttuFeed parse:feedUrl];
	
	NSUInteger storiesCount = [pttuFeed.stories count];
	
	// Check for posts in feed
	if (storiesCount == 0) {
		NSLog(@"No stories in feed: %@", self.feedUrl);
		[pttuFeed release];
		[self performSelectorOnMainThread:@selector(backgroundFeedFinished) withObject:nil waitUntilDone:YES];
		[pool release];
		return;
	}

	/*
	// Compare lastDate with most recent story date
	// to check whether the table data needs reloading
	if (lastDate && [[[pttuFeed.stories objectAtIndex:0] objectForKey:@"date"] isEqualToString:lastDate]) {
		// No need to update
		NSLog(@"No need to update");
		[pttuFeed release];
		[self performSelectorOnMainThread:@selector(backgroundFeedFinished) withObject:nil waitUntilDone:YES];
		[pool release];
		return;
	}
	*/
	
	// Update posts array
	self.stories = [[NSMutableArray alloc] initWithArray:pttuFeed.stories];

	/*
	// Update lastDate with the most recent story's date
	if (lastDate) [lastDate release];
	lastDate = [[NSString alloc] initWithString:[[posts objectAtIndex:0] objectForKey:@"date"]];
	*/
	
	NSLog(@"Did Load: Posts count %d", [self.stories count]);
	
	[pttuFeed release];
	
	// Main thread code (start activity indicator, reload table with new stories)
	[self performSelectorOnMainThread:@selector(backgroundFeedDownloaded) withObject:nil waitUntilDone:NO];
	// [self writeFeedToFile]; // Write stories
	
	// Download images
	NSUInteger n;
	for (n = 0; n < [self.stories count]; n++) {
		NSDictionary *item = [self.stories objectAtIndex:n];
		NSMutableDictionary *post = [[NSMutableDictionary alloc] initWithDictionary:item];
		NSString *type = [item objectForKey:@"enclosureType"];
		NSLog(@"enclosure type: %@", type);
		NSString *url = [item objectForKey:@"enclosure"];
		// If enclosure == image, display
		if (url && [type hasPrefix:@"video"] == FALSE && [type hasPrefix:@"audio"] == FALSE) {
			// Download image
			NSLog(@"backgroundFeed: Download image: %@", url);
			NSData *currentImage = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
			if (currentImage) [post setObject:currentImage forKey:@"imageFile"];
		}
		// Replace
		[self.stories replaceObjectAtIndex:n withObject:post];
		// Update table view to show image
		[self performSelectorOnMainThread:@selector(backgroundImageFinished:) withObject:[NSNumber numberWithInt:n] waitUntilDone:NO];
		[post release];
	}
	
	[self performSelectorOnMainThread:@selector(backgroundFeedFinished) withObject:nil waitUntilDone:NO];
	
	[pool release];
}

- (void)backgroundFeedDownloaded {
	// Feed downloaded (but will continue downloading images)
	if (self.delegate && [self.delegate respondsToSelector:@selector(feedDownloaderFeedDidFinish:)]) {
		[self.delegate feedDownloaderFeedDidFinish:self];
	}
}

- (void)backgroundImageFinished:(NSNumber *)row {
	// Image downloaded
	if (self.delegate && [self.delegate respondsToSelector:@selector(feedDownloaderDidFinish:)]) {
		[self.delegate feedDownloaderImageDidFinish:self postIndex:row];
	}
}

- (void)backgroundFeedFinished {
    // All images downloaded
	if (self.delegate && [self.delegate respondsToSelector:@selector(feedDownloaderDidFinish:)]) {
		[self.delegate feedDownloaderDidFinish:self];
	}
}


- (void)startDownloading {
    if( self.lastUpdated != nil ) {
        [self.lastUpdated release];
    }
    self.lastUpdated = [[NSDate alloc] init];
	[NSThread detachNewThreadSelector:@selector(backgroundFeed) toTarget:self withObject:nil];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[feedUrl release];
	[stories release];
    [lastUpdated release];
	[super dealloc];
}

@end
