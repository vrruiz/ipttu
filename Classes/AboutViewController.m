//
//  AboutViewController.m
//  ipttu
//
//  Created by Víctor R. Ruiz on 08/10/10.
//  Copyright 2010 European Southern Observatory & Víctor R. Ruiz. All rights reserved.
//

#import "AboutViewController.h"
#import "WebViewController.h"

@implementation AboutViewController

@synthesize delegate;
@synthesize webView;
@synthesize buttonClose;

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
    [super viewDidLoad];
	
	// Load view from file about.html
	NSBundle *bundle = [NSBundle mainBundle]; 
	NSString *path = [bundle bundlePath];
	NSString *fullPath = [NSBundle pathForResource:@"about" ofType:@"html" inDirectory:path];
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:fullPath]]];
	
	webView.delegate = self;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// On the iPad, support any orientation
		return YES;
	} else {
		// On the iPhone, just portrait orientation
	  return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
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
	if (buttonClose) [buttonClose release];
	[webView release];
    [super dealloc];
}

# pragma mark -
# pragma mark - UIWebView delegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		NSLog(@"click!");
		// Open internal web browser
		WebViewController *webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil url:[[request URL] absoluteString]];
		webViewController.hidesBottomBarWhenPushed = YES;
		webViewController.title = @"Portal to the Universe";
		[self.navigationController pushViewController:webViewController animated:YES];
		[webViewController release];
		return NO;
	}
	return YES;
}

#pragma mark -
#pragma mark Actions

- (IBAction)buttonCloseDidTouch:(id)sender {
	// On the iPad, there is a navigation bar with a close button.
	// Notify parent.
	if (self.delegate && [self.delegate respondsToSelector:@selector(aboutViewControllerDidTouch:)]) {
		[self.delegate aboutViewControllerDidTouch:self];
	}
}

@end
