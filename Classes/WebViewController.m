//
//  PostViewController.m
//  ipttu
//
//  Created by Víctor R. Ruiz on 31/08/10.
//  Copyright 2010 European Southern Observatory & Víctor R. Ruiz. All rights reserved.
//

#import "WebViewController.h"

@implementation WebViewController

@synthesize webView;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil url:(NSString *)url {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		urlAddress = [url copy];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Load address
	NSURL *url = [NSURL URLWithString:urlAddress];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[webView loadRequest:request];	
	textAddress.text = urlAddress;
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
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[urlAddress release];
	[buttonBack release];
	[buttonForward release];
	[buttonCancel release];
	[buttonRefresh release];
	[textAddress release];
	[webView release];
	
    [super dealloc];
}

# pragma mark -
# pragma mark - Button actions

- (IBAction) webBack {
	NSLog(@"Back!");
	[webView goBack];
}

- (IBAction) webForward {
	NSLog(@"Fordward!");
	[webView goForward];
}

- (IBAction) webCancel {
	NSLog(@"Cancel!");
	[webView stopLoading];
}

- (IBAction) webRefresh {
	NSLog(@"Refresh!");
	[webView reload];
}

- (IBAction) webOpenSafari {
	NSLog(@"Open safari!");
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString: webView.request.URL.absoluteString]];
}


# pragma mark -
# pragma mark - UIWebView delegate methods

-(void)webViewDidFinishLoad:(UIWebView *)wwwView
{
	// Enable or disable action buttons 
	[buttonCancel setEnabled:NO];
	[buttonRefresh setEnabled:YES];
	[buttonAction setEnabled:YES];
	
	// Enable or disable back and forward buttons
	[buttonBack setEnabled:[wwwView canGoBack]];
	[buttonForward setEnabled:[wwwView canGoForward]];
}

- (BOOL)webView:(UIWebView *)wwwView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSLog(@"shouldStartLoadWithRequest: %@", request.URL.absoluteString);
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		NSLog(@"Set address");
		// Set address URL
		textAddress.text = request.URL.absoluteString;
	}
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)wwwView {
	NSLog(@"webViewDidStartLoad");
	
	// Disable bar buttons
	[buttonCancel setEnabled:YES];
	[buttonBack setEnabled:NO];
	[buttonForward setEnabled:NO];
	[buttonRefresh setEnabled:NO];
	[buttonAction setEnabled:NO];
}

- (void)webView:(UIWebView *)wwwView didFailLoadWithError:(NSError *)error {
	// UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Network error" message:@"Check your Internet connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	// [alertView show];
	// [alertView release];
}


@end
