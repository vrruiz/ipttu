//
//  SearchViewController.m
//  ipttu
//
//  Created by Víctor R. Ruiz on 01/10/10.
//  Copyright 2010 European Southern Observatory & Víctor R. Ruiz. All rights reserved.
//

#import "SearchViewController.h"
#import "WebViewController.h"
#import "CJSONDeserializer.h"
#import "NSStringExtras.h"

@implementation SearchViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	items = [[NSMutableArray alloc] init];
	lastSearch = [[NSMutableString alloc] init];
	jsonData = [[NSMutableData alloc] init];
 
	[super viewDidLoad];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
	[lastSearch release];
	[items release];
	[connection release];
	[request release];
    [super dealloc];
}

# pragma mark -
# pragma mark - UISearchDisplayController TableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	}
	
	// Set up the cell...
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	NSString *title = [[items objectAtIndex:indexPath.row] objectForKey:@"title"];
	NSString *summary = [[items objectAtIndex:indexPath.row] objectForKey:@"summary"];
	cell.textLabel.text = [title stringByConvertingHTMLToPlainText];
	cell.textLabel.font = [UIFont boldSystemFontOfSize:12.0];
	cell.detailTextLabel.text = [summary stringByConvertingHTMLToPlainText];
	cell.detailTextLabel.font = [UIFont systemFontOfSize:10.0];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"didSelectRowAtIndexPath");
	
	// Check whether item is correctly selected
	if ([items count] < 1 || indexPath.row >= [items count]) return;
	
	// Open internal web browser
	NSString *link = [[items objectAtIndex:indexPath.row] objectForKey:@"link"];
	WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil url:link];
	webViewController.hidesBottomBarWhenPushed = YES;
	webViewController.title = @"Portal to the Universe";
	[self.navigationController pushViewController:webViewController animated:YES];
	[webViewController release];
}

# pragma mark -
# pragma mark - UISearchDisplayController delegate methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	NSLog(@"shouldReloadTableForSearchString: %@", searchString);
	return NO;
}

# pragma mark -
# pragma mark - NSURLConnection delegate methods

- (void)parseJson:(NSData *)data {
	// Parse JSON
	NSDictionary *result = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:nil];
	if (result == nil) return;
	
	// Check response
	NSNumber *status = [result objectForKey:@"responseStatus"];
	NSLog(@"Status: %d", [status intValue]);
	if (![status isEqualToNumber:[NSNumber numberWithInt:200]]) return; // Bad request
	// TODO: Alert of network problems
	
	// Parse query
	NSDictionary *response = [result objectForKey:@"responseData"];
	NSArray *results = [response objectForKey:@"results"];
	NSLog(@"count: %d", [results count]);
	if (results == nil) return;
	
	// Add items to array
	for (NSUInteger i = 0; i < [results count]; i++) {
		NSDictionary *item = [results objectAtIndex:i];
		NSString *title = [item objectForKey:@"titleNoFormatting"];
		NSString *link = [item objectForKey:@"url"];
		NSString *summary = [item objectForKey:@"content"];
		
		// Append to array
		NSMutableDictionary *newItem = [[NSMutableDictionary alloc] init];
		[newItem setObject:[title copy] forKey:@"title"];
		[newItem setObject:[link copy] forKey:@"link"];
		[newItem setObject:[summary copy] forKey:@"summary"];
		[items addObject:newItem];
		[newItem release];
	}
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	// Reset data
	[jsonData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	// Append data
	[jsonData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)conn {
	NSLog(@"DidFinishLoading");
	
	[connection release];
	connection = nil;
	
	// Parse downloaded data
	[self parseJson:jsonData];
	
	// Refresh table view
	[self.searchDisplayController.searchResultsTableView reloadData];
	
	// Hide status bar activity indicator
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

# pragma mark -
# pragma mark - UISearchDisplayController SearchBar delegate methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	NSLog(@"textDidChange");
	
	// Avoid calls to Google AJAX API. 1st pass
	if ([lastSearch isEqualToString:searchText]) return; // Already done

	// Reset items
	if ([items count] > 0) [items removeAllObjects];

	// Avoid calls to Google AJAX API. 2nd pass
	if ([searchText isEqualToString:@""]) return; // No search needed
	if ([searchText length] < 2) return; // No search needed

	[lastSearch setString:searchText];

	// Show status bar activity indicator
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	// Compose URL
	NSMutableString *urlString = [[NSMutableString alloc] initWithString:@"http://ajax.googleapis.com/ajax/services/search/web?v=1.0&cx=016374242383990648147%3A8xa_ayqhnne&rsz=large&q="];
	[urlString appendString:[searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSURL *url = [NSURL URLWithString:urlString];
	[urlString release];
	
	// Download data: Asynchronous downloading
	if (connection) {
		// Stop previous request
		[connection cancel];
		[connection release];
	}
	
	// Start new request
	request = [[NSURLRequest alloc] initWithURL:url];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[connection start];
	[request release];
}

@end
