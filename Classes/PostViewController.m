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
#import <MediaPlayer/MPMoviePlayerController.h>

@implementation PostViewController

@synthesize labelTitle;
@synthesize labelDate;
@synthesize labelCreator;
@synthesize imageView;
@synthesize textView;
@synthesize item;
@synthesize scrollView;
@synthesize bottomToolbar;
@synthesize buttonAction;
@synthesize imageThread;
@synthesize imageData;

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

#pragma mark -
#pragma mark Download the image asynchronously with NSURLConnection and NSMutableData

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	// NSLog(@"didReceiveResponse");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	// New data available, append
	[imageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	// Data downloaded. Show image.
	[item setObject:imageData forKey:@"imageFile"];
	UIImage *image = [[UIImage alloc] initWithData:imageData];
	if (image) {
		imageView.image = [image imageByScalingAndCroppingForSize:imageView.frame.size];
		[image release];
	}
	[imageData release];
}

- (void)backgroundAsyncImage {
	// Background asynchronous downloading
	NSString *url = [item objectForKey:@"enclosure"];
	NSString *type = [item objectForKey:@"enclosureType"];
	if (url && [type hasPrefix:@"audio"] == FALSE && [type hasPrefix:@"video"] == FALSE) {
		imageData = [[NSMutableData alloc] init];
		NSURLRequest *request = [[NSURLRequest alloc] initWithURL: [NSURL URLWithString:url]]; 
		NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		[connection release];
		[request release];
	}
}

#pragma mark -
#pragma mark View methods

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	imageThread = nil;
	
	labelTitle.text = [item objectForKey:@"title"];
	labelDate.text = [item objectForKey:@"date"];
	labelCreator.text = [item objectForKey:@"dc:creator"];
	textView.text = [item objectForKey:@"summary"];
	
	NSString *type = [item objectForKey:@"enclosureType"];
	if (type && ([type hasPrefix:@"audio"] || [type hasPrefix:@"video"])) {
		// Play button
		buttonPlay = [[UIBarButtonItem alloc]
					  initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
					  target:self
					  action:@selector(openBrowser)];
		buttonPlay.style = UIBarButtonItemStyleBordered;
		
		// Replace the "Read more..." button with this one in the bottom bar
		NSMutableArray *barItems = [bottomToolbar.items mutableCopy];
		[barItems replaceObjectAtIndex:1 withObject:buttonPlay];
		bottomToolbar.items = barItems;
 		[barItems release];

		/* self.navigationItem.rightBarButtonItem = buttonPlay; */
	} else {
		// Link button
		/*
		buttonLink = [[UIBarButtonItem alloc]
					  initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
					  target:self
					  action:@selector(openBrowser)];
		self.navigationItem.rightBarButtonItem = buttonLink;
		*/
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
			[self backgroundAsyncImage];
		}
	}
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

- (void)viewWillDisappear:(BOOL)animated {
	NSLog(@"Stop thread");
	[imageThread cancel];
	[imageThread release];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
	if (buttonPlay) [buttonPlay release];
	if (buttonLink) [buttonLink release];
	[buttonAction release];
	[bottomToolbar release];
	[item release];
	[labelTitle release];
	[labelDate release];
	[labelCreator release];
	[imageView release];
	[textView release];
	[scrollView release];

    [super dealloc];
}


@end
