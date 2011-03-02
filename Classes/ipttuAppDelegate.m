//
//  ipttuAppDelegate.m
//  ipttu
//
//  Created by Víctor R. Ruiz on 31/08/10.
//  Copyright European Southern Observatory & Víctor R. Ruiz 2010. All rights reserved.
//

#import "ipttuAppDelegate.h"
#import "iPhoneViewController.h"
#import "NewsController.h"

@implementation ipttuAppDelegate

@synthesize window;
@synthesize iphoneViewController;
@synthesize ipadViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	// Select device
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// iPad
		ipadViewController = [[NewsController alloc] initWithNibName:@"NewsController" bundle:nil];
		
		// Fix view positioning (below status bar if not modified)
		CGRect rectFix = ipadViewController.view.frame;
		rectFix = CGRectOffset(rectFix, 0.0, 20.0);
		ipadViewController.view.frame = rectFix;
		
		[window addSubview:ipadViewController.view];
	} else {
		// iPhone
		iphoneViewController = [[iPhoneViewController alloc] initWithNibName:@"iPhoneViewController" bundle:nil];
		[window addSubview:iphoneViewController.view];
	}
	
    [window makeKeyAndVisible];
	return YES;
}

- (void)dealloc {
	if (iphoneViewController) [iphoneViewController release];
	if (ipadViewController) [ipadViewController release];
    [window release];
    [super dealloc];
}


@end
