//
//  PostViewController.m
//  ipttu
//
//  Created by Víctor R. Ruiz on 01/09/10.
//  Copyright 2010 European Southern Observatory & Víctor R. Ruiz. All rights reserved.
//

#import "PostViewController.h"
#import "UIImageExtras.h"
#import "WebViewController.h"

#import <SystemConfiguration/SCNetworkReachability.h>
#import <MediaPlayer/MPMoviePlayerViewController.h>

@implementation PostViewController

@synthesize labelTitle;
@synthesize labelDate;
@synthesize imageView;
@synthesize textView;
@synthesize item;
@synthesize scrollView;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil item:(NSMutableDictionary *)_item {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		NSLog(@"PostViewController. initWithNibName. item: %d", [_item objectForKey:@"title"]);
		item = [[NSMutableDictionary alloc] initWithDictionary:_item];
    }
    return self;
}

- (BOOL)isDataSourceAvailable
{
	// Snippet: http://stackoverflow.com/questions/741145/determining-internet-availability-on-iphone
	Boolean success;    
	const char *host_name = "portaltotheuniverse.org"; // your data source host name
	
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host_name);
	SCNetworkReachabilityFlags flags;
	success = SCNetworkReachabilityGetFlags(reachability, &flags);
	BOOL _isDataSourceAvailable = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
	CFRelease(reachability);
	
    return _isDataSourceAvailable;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	labelTitle.text = [item objectForKey:@"title"];
	labelDate.text = [item objectForKey:@"date"];
	textView.text = [item objectForKey:@"summary"];
	imageView.image = [[UIImage imageNamed:@"Default.png"] imageByScalingAndCroppingForSize:imageView.frame.size];
	
	NSString *type = [item objectForKey:@"enclosureType"];
	if (type && ([type hasPrefix:@"audio"] || [type hasPrefix:@"video"])) {
		// Play button
		buttonPlay = [[UIBarButtonItem alloc]
					  initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
					  target:self
					  action:@selector(openBrowser)];
		self.navigationItem.rightBarButtonItem = buttonPlay;
	} else {
		// Link button
		buttonLink = [[UIBarButtonItem alloc]
					  initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
					  target:self
					  action:@selector(openBrowser)];
		self.navigationItem.rightBarButtonItem = buttonLink;
	}
	
	// Resize image
	NSData *data = [item objectForKey:@"imageFile"];
	if (data) {
		UIImage *image = [[[UIImage alloc] initWithData:data] autorelease];
		imageView.image = [image imageByScalingAndCroppingForSize:imageView.frame.size];
	} else {
		// Check network availability
		if ([self isDataSourceAvailable]) {
			// Download image
			NSString *url = [item objectForKey:@"enclosure"];
			NSString *type = [item objectForKey:@"enclosureType"];
			if (url && [type hasPrefix:@"video"] == FALSE && [type hasPrefix:@"audio"] == FALSE)
				[NSThread detachNewThreadSelector:@selector(backgroundImage)
											  toTarget:self
											withObject:nil];
		}
	}
}

- (void) backgroundImage {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *url = [item objectForKey:@"enclosure"];
	NSString *type = [item objectForKey:@"enclosureType"];
	if (url && [type hasPrefix:@"audio"] == FALSE && [type hasPrefix:@"video"] == FALSE) {
		// Download image
		NSData *currentImage = [[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]] autorelease];
		[item setObject:[currentImage copy] forKey:@"imageFile"];

		// Refresh view
		[self performSelectorOnMainThread:@selector(backgroundImageFinished) withObject:nil waitUntilDone:YES];
	}

	[pool release];
}

- (void) backgroundImageFinished {
	UIImage *image = [[[UIImage alloc] initWithData:[item objectForKey:@"imageFile"]] autorelease];
	if (image) imageView.image = [image imageByScalingAndCroppingForSize:imageView.frame.size];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void) openBrowser {
	NSString *type = [item objectForKey:@"enclosureType"];
	NSString *enclosure = [item objectForKey:@"enclosure"];
	if (enclosure && type && ([type hasPrefix:@"audio"] || [type hasPrefix:@"video"])) {
		// Play podcast
		NSURL *url = [[NSURL alloc] initWithString:enclosure];
		MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
		if (player) {
			NSLog(@"Player");
			[player.moviePlayer setFullscreen:YES animated:YES];
			[player.moviePlayer prepareToPlay];
			[player.moviePlayer play];
			[self presentMoviePlayerViewControllerAnimated:player];
		} else {
			NSLog(@"No player");
		}
		[player release];
		[url release];
	} else {
		// Open link in browser
		NSString *link = [item objectForKey:@"link"];
		if (link) {
			// Use internal web browser
			WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil url:link];
			[self.navigationController pushViewController:webViewController animated:YES];
			[webViewController release];
		}
	}
}

- (IBAction) openSafari:(id)sender {
	[self openBrowser];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	if (buttonPlay) [buttonPlay release];
	if (buttonLink) [buttonLink release];
	[item release];
	[labelTitle release];
	[labelDate release];
	[imageView release];
	[textView release];
	[scrollView release];

    [super dealloc];
}


@end
