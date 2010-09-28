//
//  FeaturedTableViewController.m
//  ipttu
//
//  Created by Víctor R. Ruiz on 31/08/10.
//  Copyright 2010 European Southern Observatory & Víctor R. Ruiz. All rights reserved.
//

#import "FeaturedTableViewController.h"
#import "PTTUFeed.h"
#import "WebViewController.h"
#import "PostViewController.h"
#import "UIImageExtras.h"

#import <SystemConfiguration/SCNetworkReachability.h>
#import <CommonCrypto/CommonDigest.h>
#import <MediaPlayer/MPMoviePlayerViewController.h>

@implementation FeaturedTableViewController

@synthesize feed;
@synthesize file;
@synthesize tabController;
@synthesize navController;
@synthesize buttonRefresh;

#pragma mark -
#pragma mark View lifecycle


// Snippet: http://stackoverflow.com/questions/741145/determining-internet-availability-on-iphone
- (BOOL)isDataSourceAvailable
{
	Boolean success;    
	const char *host_name = "portaltotheuniverse.org"; // your data source host name
	
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host_name);
	SCNetworkReachabilityFlags flags;
	success = SCNetworkReachabilityGetFlags(reachability, &flags);
	BOOL _isDataSourceAvailable = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
	CFRelease(reachability);
	
    return _isDataSourceAvailable;
}

// Snippet: http://stackoverflow.com/questions/652300/using-md5-hash-on-a-string-in-cocoa
- (NSString*)md5HexDigest:(NSString*)input {
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
	
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

- (void) alertInternet {
	UIAlertView *errorAlert = [[UIAlertView alloc]
							   initWithTitle: @"Warning"
							   message: @"PTTU web site not available. Check your Internet connection. Showing cached stories."
							   delegate:nil
							   cancelButtonTitle:@"OK"
							   otherButtonTitles:nil];
	[errorAlert show];
	[errorAlert release];
}

- (void)viewDidLoad {
    [super viewDidLoad];

	/*
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

	
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	*/
	
	// tvCell height
	self.tableView.rowHeight = 70;
	
	// Activity indicator
	activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
	buttonActivity = [[UIBarButtonItem alloc] initWithCustomView:activityView];
	
	// Set caché file name
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	// Uses hash
	file = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:[self md5HexDigest:feed]]];
	NSLog(@"FeaturedTableViewController. DidLoad. file: %@", file);

	// Read caché
	NSMutableArray *stories = [[NSMutableArray alloc] initWithContentsOfFile:file];
	if (stories) {
		NSLog(@"Stories file count: %d", [stories count]);
		// Reload?
		lastDate = [[NSString alloc] initWithString:[[stories objectAtIndex:0] objectForKey:@"date"]];
		posts = [stories copy];
	} else {
		NSLog(@"Stories file count: nil");
	}
	[stories release];
	
	// Check network status
	if ([self isDataSourceAvailable]) {
		// Download stories in background
		[NSThread detachNewThreadSelector:@selector(backgroundFeed) toTarget:self withObject:nil];
	} else {
		// Network not available. Show alert.
		[self alertInternet];
	}
}

- (void) writeFeedToFile {
	// Write stories to disk
	NSLog(@"Background: Writing stories to disk");
	[posts writeToFile:file atomically:YES];
}

- (void) backgroundFeed {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	// Main thread code (start activity indicator)
	[self performSelectorOnMainThread:@selector(backgroundFeedStarted) withObject:nil waitUntilDone:NO];
	
	// TODO: Check errors http://www.portaltotheuniverse.org/static/images/rss.png
	// [pttuFeed parse:@"http://www.portaltotheuniverse.org/rss/news/featured/"];
	NSLog(@"FeaturedTableViewController: ViewDidLoad. Feed: %@", feed);
	PTTUFeed *pttuFeed = [[PTTUFeed alloc] init];
	[pttuFeed parse:feed];
	
	// Compare lastDate with most recent story date
	// to check whether the table data needs reloading
	NSLog(@"Last date %@ -- Feed last date: %@", lastDate, [[pttuFeed.stories objectAtIndex:0] objectForKey:@"date"]);
	if (lastDate && [pttuFeed.stories count] > 0 && [[[pttuFeed.stories objectAtIndex:0] objectForKey:@"date"] isEqualToString:lastDate]) {
		// No need to update
		NSLog(@"No need to update");
		[pttuFeed release];
		[self performSelectorOnMainThread:@selector(backgroundFeedFinished) withObject:nil waitUntilDone:YES];
		[pool release];
		return;
	}

	// Update posts array
	if (posts) [posts release];
	posts = [[NSMutableArray alloc] initWithArray:pttuFeed.stories];
	
	// Update lastDate with the most recent story's date
	if (lastDate) [lastDate release];
	lastDate = [[NSString alloc] initWithString:[[posts objectAtIndex:0] objectForKey:@"date"]];
	
	NSLog(@"Did Load: Posts count %d", [posts count]);
	
	[pttuFeed release];
	
	// Main thread code (start activity indicator, reload table with new stories)
	[self performSelectorOnMainThread:@selector(backgroundFeedDownloaded) withObject:nil waitUntilDone:YES];
	[self writeFeedToFile]; // Write stories
	
	// Download images
	NSUInteger n;
	for (n = 0; n < [posts count]; n++) {
		NSDictionary *item = [posts objectAtIndex:n];
		NSMutableDictionary *post = [[[NSMutableDictionary alloc] initWithDictionary:[item copy]] autorelease];
		NSString *type = [item objectForKey:@"enclosureType"];
		NSLog(@"enclosure type: %@", type);
		NSString *url = [item objectForKey:@"enclosure"];
		// If enclosure == image, display
		if (url && [type hasPrefix:@"video"] == FALSE && [type hasPrefix:@"audio"] == FALSE) {
			// Download image
			NSLog(@"backgroundFeed: Download image: %@", url);
			NSData *currentImage = [[NSData dataWithContentsOfURL:[NSURL URLWithString:url]] autorelease];
			if (currentImage) [post setObject:[currentImage copy] forKey:@"imageFile"];
		}
		// Replace
		[posts replaceObjectAtIndex:n withObject:[post copy]];
		// Update table view to show image
		[self performSelectorOnMainThread:@selector(backgroundImageFinished:) withObject:[NSNumber numberWithInt:n] waitUntilDone:YES];
	}

	[self performSelectorOnMainThread:@selector(backgroundFeedFinished) withObject:nil waitUntilDone:YES];
	[self performSelectorOnMainThread:@selector(writeFeedToFile) withObject:nil waitUntilDone:YES];

	[pool release];
}

- (void) backgroundImageFinished:(NSNumber *)row {
	// Reload image
	NSLog(@"Background: Image %d downloaded", [row intValue]);

	// Compose index path
	NSUInteger indexArr[] = {0, [row intValue]};
	NSIndexPath *index = [[NSIndexPath alloc] initWithIndexes:indexArr length:2];

	// Reload the row at the index path
	// Alternative: [self.tableView reloadData] -- but is slower
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationNone];

	[index release];
}

- (void) backgroundFeedStarted {
	// Start activity indicator
	[activityView startAnimating];
	// Replace refresh icon with the activity indicator
    self.navigationItem.rightBarButtonItem = buttonActivity;

}

- (void) backgroundFeedDownloaded {
	// Reload table
	NSLog(@"Background: Reload table");
	[self.tableView reloadData];
}

- (void) backgroundFeedFinished {
	// Write images to file
	NSLog(@"Background: Feed finished");
	[self writeFeedToFile]; // Write stories --with images

	// Replace activity icon with the original, refresh
	self.navigationItem.rightBarButtonItem = buttonRefresh;
	// Stop activity indicator
	[activityView stopAnimating];
}

/*
- (void)viewWillAppear:(BOOL)animated {
	self.tabController.tabBar.hidden = NO;
    [super viewWillAppear:animated];
}
*/

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

/*
- (void)viewWillDisappear:(BOOL)animated {
	self.tabController.tabBar.hidden = YES;
    [super viewWillDisappear:animated];
}
*/

/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [posts count];
}

// Source: http://rudis.net/content/2009/01/21/flatten-html-content-ie-strip-tags-cocoaobjective-c
- (NSString *)removeHTML:(NSString *)html {
    NSScanner *theScanner;
    NSString *text = nil;
	
    theScanner = [NSScanner scannerWithString:html];
	
    while ([theScanner isAtEnd] == NO) {
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ; 
		
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
		
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@" "];
		
    }
    return html;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *MyIdentifier = @"Cell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	
    if (cell == nil) {
		// Load custom Cell View from XIB file
        [[NSBundle mainBundle] loadNibNamed:@"tvCell" owner:self options:nil];
		if (tvCell == nil) {
			NSLog(@"tvCell is nil");
		}
        cell = tvCell;
        // self.tvCell = nil; // Comment this. Is Apple official doc wrong?
    }
	
	int storyIndex = [indexPath indexAtPosition:[indexPath length] - 1];
	
	// Image
	UIImageView *imageView;
	imageView = (UIImageView *)[cell viewWithTag:1];
	UIImage *image = [[[UIImage alloc] initWithData:[[posts objectAtIndex: storyIndex] objectForKey: @"imageFile"]] autorelease];
	if (image) imageView.image = [image imageByScalingAndCroppingForSize:imageView.frame.size];
	
	// Audio/video podcast?
	NSString *type = [[posts objectAtIndex:storyIndex] objectForKey:@"enclosureType"];
	if (type && ([type hasPrefix:@"audio"] || [type hasPrefix:@"video"])) {
		NSString *iconFile = [type hasPrefix:@"audio"] ? @"icon-audio.png" : @"icon-video.png";
		imageView.contentMode = UIViewContentModeCenter;
		imageView.image = [UIImage imageNamed:iconFile];
	}
	
	// Title
    UILabel *label;
    label = (UILabel *)[cell viewWithTag:2];
	label.text = [[posts objectAtIndex:storyIndex] objectForKey: @"title"];
	
	// Date
    // label = (UILabel *)[cell viewWithTag:3];
	// label.text = [[posts objectAtIndex:storyIndex] objectForKey: @"date"];
	NSString *date = [[posts objectAtIndex:storyIndex] objectForKey: @"shortDate"];
	
	// Description
    label = (UILabel *)[cell viewWithTag:4];
	NSString *summary = [[posts objectAtIndex:storyIndex] objectForKey: @"summary"];
	summary = [self removeHTML:summary];
	label.text = [NSString stringWithFormat:@"%@ - %@", date, summary];
	
    return cell;	
}

// Click on refresh button
- (IBAction) refresh: (id)sender {
	// Download stories in background
	if ([self isDataSourceAvailable]) {
		// Download stories in background
		[NSThread detachNewThreadSelector:@selector(backgroundFeed) toTarget:self withObject:nil];
	} else {
		// Web not available. Alert
		[self alertInternet];
	}
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	int storyIndex = [indexPath indexAtPosition:[indexPath length] - 1];

	NSLog(@"FeaturedTableViewController. didSelectRowAtIndexPath. post.");
	NSMutableDictionary *post = [posts objectAtIndex:storyIndex];
	
	// Show post view
	NSLog(@"FeaturedTableViewController. didSelectRowAtIndexPath. postViewController.");
	PostViewController *postViewController = [[PostViewController alloc] initWithNibName:@"PostViewController" bundle:nil item:[post copy]];
	postViewController.hidesBottomBarWhenPushed = YES;
	postViewController.title = [post objectForKey:@"title"];
	[navController pushViewController:postViewController animated:YES];
	[postViewController release];

}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	if (lastDate) [lastDate release];
	if (posts) [posts release];
	[buttonActivity release];
	[buttonRefresh release];
	[navController release];
	[tabController release];
	[feed release];
	[file release];
	[tvCell release];
	[activityView release];
    [super dealloc];
}


@end

