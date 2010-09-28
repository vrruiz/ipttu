//
//  ipttuAppDelegate.m
//  ipttu
//
//  Created by Víctor R. Ruiz on 31/08/10.
//  Copyright European Southern Observatory & Víctor R. Ruiz 2010. All rights reserved.
//

#import "ipttuAppDelegate.h"
#import "FeaturedNavController.h"

@implementation ipttuAppDelegate

@synthesize window;
@synthesize rootController;
@synthesize featuredNavController;
@synthesize blogNavController;
@synthesize podcastNavController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    // Override point for customization after application launch
	
	// This sets the feed URLs
	featuredNavController.feed = @"http://www.portaltotheuniverse.org/rss/news/featured/";
	blogNavController.feed = @"http://www.portaltotheuniverse.org/rss/blogs/posts/featured/";
	podcastNavController.feed = @"http://www.portaltotheuniverse.org/rss/podcasts/eps/featured/";

	[window addSubview:rootController.view];
    [window makeKeyAndVisible];
	
	return YES;
}

- (void)dealloc {
	[rootController release];
	[featuredNavController release];
	[blogNavController release];
	[podcastNavController release];
    [window release];
    [super dealloc];
}


@end
