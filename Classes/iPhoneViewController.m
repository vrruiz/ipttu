//
//  iPhoneViewController.m
//  ipttu
//
//  Created by Víctor R. Ruiz on 02/03/11.
//  Copyright 2011 European Southern Observatory & Víctor R. Ruiz. All rights reserved.
//

#import "iPhoneViewController.h"
#import "FeaturedNavController.h"

@implementation iPhoneViewController

@synthesize rootController;
@synthesize featuredNavController;
@synthesize blogNavController;
@synthesize podcastNavController;


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	featuredNavController.feed = @"http://www.portaltotheuniverse.org/rss/news/featured/";
	blogNavController.feed = @"http://www.portaltotheuniverse.org/rss/blogs/posts/featured/";
	podcastNavController.feed = @"http://www.portaltotheuniverse.org/rss/podcasts/eps/featured/";
	
	self.view = rootController.view;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[rootController release];
	[featuredNavController release];
	[blogNavController release];
	[podcastNavController release];
    [super dealloc];
}


@end
